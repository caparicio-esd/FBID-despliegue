package es.upm.dit.ging.predictor

import com.datastax.spark.connector.CassandraSparkExtensions
import org.apache.spark.ml.classification.RandomForestClassificationModel
import org.apache.spark.ml.feature.VectorAssembler
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions.{col, concat, expr, from_json, lit, struct, to_json}
import org.apache.spark.sql.types.{DataTypes, StructType}

object MakePredictionCassandra {

  def main(args: Array[String]): Unit = {

    // envs
    val isDocker = sys.env.get("IS_DOCKER_ENV").exists(_.equals("1"))
    val mongoHost = sys.env.getOrElse("MONGO_HOST", "127.0.0.1")
    val mongoPort = sys.env.getOrElse("MONGO_PORT", "27017")
    val mongoDb = sys.env.getOrElse("MONGO_DB", "agile_data_science")
    val mongoCollection = sys.env.getOrElse("MONGO_COLLECTION", "flight_delay_classification_response")
    val cassandraHost = sys.env.getOrElse("CASSANDRA_HOST", "127.0.0.1")
    val cassandraPort = sys.env.getOrElse("CASSANDRA_PORT", "9042")
    val cassandraKeySpace = sys.env.getOrElse("CASSANDRA_KEYSPACE", "agile_data_science")
    val cassandraTable = sys.env.getOrElse("CASSANDRA_TABLE", "flight_delay_classification_response")
    val kafkaHost = sys.env.getOrElse("KAFKA_HOST", "127.0.0.1")
    val kafkaPort = sys.env.getOrElse("KAFKA_PORT", "9092")
    val kafkaTopicSuscribe = sys.env.getOrElse("KAFKA_REQUEST_TOPIC", "flight_delay_classification_request")
    val kafkaTopicSink = sys.env.getOrElse("KAFKA_RESPONSE_TOPIC", "flight_delay_classification_response")


    val spark = SparkSession
      .builder
      .appName("MakePredictionCassandra")
      .master("local[*]")
      .withExtensions(new CassandraSparkExtensions)
      .getOrCreate()

    import spark.implicits._
    spark.sparkContext.setLogLevel("WARN")

    /**
     * Load vectorassembler and inference model
     */
    println(isDocker)
    val base_path=
      if (!isDocker) "/Users/apabook/Desktop/fbid"
      else ""
    val vectorAssemblerPath = s"$base_path/models/numeric_vector_assembler.bin"
    val randomForestModelPath =
      s"$base_path/models/spark_random_forest_classifier.flight_delays.5.0.bin"
    val vectorAssembler = VectorAssembler.load(vectorAssemblerPath)
    val inferenceModel = RandomForestClassificationModel.load(randomForestModelPath)


    /**
     * Stream reader
     */
    val df = spark
      .readStream
      .format("kafka")
      .option("kafka.bootstrap.servers", s"$kafkaHost:$kafkaPort")
      .option("subscribe", kafkaTopicSuscribe)
      .load()

    /**
     * Transform pipeline
     */
    val originalFromKafkaDF = df.selectExpr("CAST(value AS STRING)")

    val schema = new StructType()
      .add("Origin", DataTypes.StringType)
      .add("FlightNum", DataTypes.StringType)
      .add("DayOfWeek", DataTypes.IntegerType)
      .add("DayOfYear", DataTypes.IntegerType)
      .add("DayOfMonth", DataTypes.IntegerType)
      .add("Dest", DataTypes.StringType)
      .add("DepDelay", DataTypes.DoubleType)
      .add("Prediction", DataTypes.StringType)
      .add("Timestamp", DataTypes.TimestampType)
      .add("FlightDate", DataTypes.DateType)
      .add("Carrier", DataTypes.StringType)
      .add("UUID", DataTypes.StringType)
      .add("Distance", DataTypes.DoubleType)
      .add("Carrier_index", DataTypes.DoubleType)
      .add("Origin_index", DataTypes.DoubleType)
      .add("Dest_index", DataTypes.DoubleType)
      .add("Route_index", DataTypes.DoubleType)

    val flightNestedDF = originalFromKafkaDF.select(
      from_json($"value", schema).as("flight")
    )

    val flightFlattenedDF = flightNestedDF.selectExpr(
      "flight.Origin",
      "flight.DayOfWeek",
      "flight.DayOfYear ",
      "flight.DayOfMonth",
      "flight.Dest",
      "flight.DepDelay",
      "flight.Timestamp",
      "flight.FlightDate",
      "flight.Carrier",
      "flight.UUID as uuid",
      "flight.Distance",
      "flight.Carrier_index",
      "flight.Origin_index",
      "flight.Dest_index",
      "flight.Route_index"
    )

    val predictionRequestDF = flightFlattenedDF.withColumn(
      "Route",
      concat(
        flightFlattenedDF("Origin"),
        lit('-'),
        flightFlattenedDF("Dest")
      )
    )


    /**
     * vectorize pipeline
     */
    val vectorizedFeatures = vectorAssembler
      .setHandleInvalid("keep")
      .transform(predictionRequestDF)

    val finalVectorizedFeatures = vectorizedFeatures
        .drop("Carrier_index")
        .drop("Origin_index")
        .drop("Dest_index")
        .drop("Route_index")

    /**
     * inference pipeline
     */
    val predictions = inferenceModel
      .transform(finalVectorizedFeatures)

    val finalPredictions = predictions
      .drop("Features_vec")
      .drop("indices")
      .drop("values")
      .drop("rawPrediction")
      .drop("probability")


    /**
     * Sink into mongo
     */
    val mongoStreamingQuery = finalPredictions
      .writeStream
      .format("mongodb")
      .option("spark.mongodb.connection.uri", s"mongodb://$mongoHost:$mongoPort")
      .option("spark.mongodb.database", mongoDb)
      .option("checkpointLocation", "/tmp/mongo")
      .option("spark.mongodb.collection", mongoCollection)
      .outputMode("append")
      .start()

    /**
     * Sink into cassandra
     */
    val cassandraStreamingQuery = finalPredictions
      .writeStream
      .format("org.apache.spark.sql.cassandra")
      .option("spark.cassandra.connection.host", cassandraHost)
      .option("spark.cassandra.connection.port", cassandraPort)
      .option("keyspace", cassandraKeySpace)
      .option("table", cassandraTable)
      .option("checkpointLocation", "/tmp/cassandra")
      .outputMode("append")
      .start()


    /**
     * Sink into kafka
     */
    val kafkaStreamingQuery = finalPredictions
      .select(
        col("uuid").as("key"),
        to_json(struct(finalPredictions.columns.map(col): _*)).as("value")
      )
      .writeStream
      .format("kafka")
      .option("kafka.bootstrap.servers", s"$kafkaHost:$kafkaPort")
      .option("topic", kafkaTopicSink)
      .option("checkpointLocation", "/tmp/kafka")
      .outputMode("append")
      .start()

    /**
     * Sink into console for testing purposes
     */
    val consoleStreamingQuery = finalPredictions.writeStream
      .outputMode("append")
      .format("console")
      .start()

    mongoStreamingQuery.awaitTermination()
    cassandraStreamingQuery.awaitTermination()
    kafkaStreamingQuery.awaitTermination()
    consoleStreamingQuery.awaitTermination()
  }
}
