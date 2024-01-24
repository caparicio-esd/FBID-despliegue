# Predicción de vuelos - FBID


Autor: Carlos Aparicio <br>
MUIRST 23-24 

---

Este proyecto se basa en tres despliegues: 

- Bare-bones: Con el software descargado y listo para usar, con sistemas de instalación, setup, entrenamiento, inicialización del job de predicción en Spark-Streaming, e inicialización de tres servidores: uno para mongo, uno para cassandra, y uno para kafka
- Docker compose: Basado en sistema docker compose, donde tenemos todo el sistema de microservicios funcionando con scripts de inicialización. Esta base la hemos usado para despliegue en Compute Engine de GCloud
- Kubernetes: Work-in-progress

## Bare-bones

### Despliegue

Para hacer el despliegue en bare-bones tenemos que seguir los siguientes pasos: 

**Instalación de librerías y creación de venv**

```bash
chmod +x ./scripts/01-install.sh
./scripts/01-install.sh
```

**Inicialización de servicios kafka, zookeeper, cassandra y mongo, y población de bases de datos**

```bash
chmod +x ./scripts/02-setup.sh
./scripts/02-setup.sh
```

**Entrenamiento de modelo con PySpark**

```bash
chmod +x ./scripts/03-train.sh
./scripts/03-train.sh
```

**Lanzamiento del job de predicción con Spark Streaming**

```bash
chmod +x ./scripts/04-flight-predictor.sh
./scripts/04-flight-predictor.sh
```

**Inicialización de servidores mongo, cassandra y kafka**

```bash
chmod +x ./scripts/05a-init-webapp-mongo.sh
chmod +x ./scripts/05b-init-webapp-cassandra.sh
chmod +x ./scripts/05c-init-webapp-kafka.sh

./scripts/05a-init-webapp-mongo
./scripts/05b-init-webapp-cassandra.sh
./scripts/05c-init-webapp-kafka.sh
```

### Testeo del entorno

Se puede navegar a: 

- http://127.0.0.1:5001/flights/delays/predict_kafka para testear con mongo como base de datos
- http://127.0.0.1:5002/flights/delays/predict_kafka para testear con cassandra como base de datos
- http://127.0.0.1:5003/flights/delays/predict_kafka para testear con kafka como entorno de persistencia

## Docker

### Despliegue

Para hacer el despliegue en docker, tenemos que ir a la carpeta `/docker`, y desde ahí desplegar el sistema

```bash
cd docker
docker compose up --build
```

Una vez se hayan levantado los servicios, desplegamos el spark-submit

```bash
docker compose -f docker-compose.submit.yaml up --build
```

### Testeo de entorno

- http://127.0.0.1:5001/flights/delays/predict_kafka para testear con mongo como base de datos
- http://127.0.0.1:5002/flights/delays/predict_kafka para testear con cassandra como base de datos
- http://127.0.0.1:5003/flights/delays/predict_kafka para testear con kafka como entorno de persistencia

### Despliegue en GCloud

Este proyecto está desplegado en una máquina virtual de Compute Engine en GCloud con docker compose. Se puede acceder al proyecto en las siguientes IPs. 

- http://34.175.52.68:5001/flights/delays/predict_kafka para testear con mongo como base de datos
- http://34.175.52.68:5002/flights/delays/predict_kafka para testear con cassandra como base de datos
- http://34.175.52.68:5003/flights/delays/predict_kafka para testear con kafka como entorno de persistencia

(Disclaimer, si la IP está caída, es por ahorra créditos, levantaré el proyecto para el examen oral)

## Kubernetes

Work in progress…