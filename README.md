# Aloes docker

Compose every dependencies needed to get a fully working Aloes network

## Install docker

[Docs](https://docs.docker.com/install/linux/docker-ce/ubuntu/)


## Install docker-compose

[Docs](https://docs.docker.com/compose/install/)


## Run as non-root user

```bash
sudo groupadd docker
sudo usermod -aG docker <non-root user>
```

## Enable autorestart at boot

```bash
sudo systemctl enable docker.service
```
## Solve "real" ip issues

Many developers using nginx inside docker uncountered this [issue](https://github.com/jwilder/nginx-proxy/issues/133)

Update hosts file to point your servername to the loopback network ( not sure it helped ).


## Setup

Manually :

- Create `.env` at root 

- Create `.env.local` and/or `.env` in `./config/device-manager/`

- Create `.env.local` and/or `.env` in `./config/mongo/`

- Create `.env.local` and/or `.env` in `./config/influxdb/`

or using helper :

```bash
chmod a+x ./aloes.sh

./aloes.sh --command create

./aloes.sh -c create -e local
```

If you intend to run in local mode ( no domain redirection ), you just have to configure environment variables and config files.

## Create HTTPS certificates

- First you have to configure properly PROXY_SERVER_HOST and PROXY_DOMAIN in `.env`.

Using helper, after creating environment variables, you will be asked to generate SSL certs too :

```bash
./aloes.sh -c create --env production
```

## Backup and restore MongoDB

```bash
chmod a+x ./config/mongo/mongodump.sh
./config/mongo/mongodump.sh -db aloes_test -c aloes-docker_mongo_1 -u aloes --password example

chmod a+x ./config/mongo/mongorestore.sh
./config/mongo/mongorestore.sh -d aloes_test -db aloes_test -c aloes-docker_mongo_1 -u aloes -p example
```

## Backup and restore InfluxDB

```bash
chmod a+x ./config/influx/influxdump.sh
./config/influx/influxdump.sh -db aloes_test -c aloes-docker_influxdb_1 -u aloes --password example

chmod a+x ./config/influx/influxrestore.sh
./config/influx/influxrestore.sh -d aloes_test -db aloes_test -c aloes-docker_influxdb_1 -u aloes -p example
```

## Display config

```bash
docker-compose config

docker-compose -f docker-compose.yml config
```
or using helper :

```bash
./test-conf.sh

./test-conf.sh -e production
```

## Build

```bash
docker-compose --compatibility build 

docker-compose --compatibility -f docker-compose.yml build 

docker-compose  -f docker-compose.yml build <service_name>

docker-compose  -f docker-compose.yml --no-deps --build <service_name> up
```
or using helper :

```bash
./aloes.sh --command build

./aloes.sh -c build --env production

./aloes.sh -c build -e local --service <service_name>
```

## Start

```bash
docker-compose --compatibility up 

docker-compose --compatibility up -d

docker-compose --compatibility -f docker-compose.yml up -d
```
or using helper :

```bash
./aloes.sh -c start

./aloes.sh -c start -e production

./aloes.sh -c start -e local -s <service_name>
```


## Stop

```bash
docker-compose --compatibility down

docker-compose -f docker-compose.yml down
```
or using helper :

```bash
./aloes.sh -c stop

./aloes.sh -c stop -e production

./aloes.sh -c stop -e local -s <service_name>
```


## Monitor

```bash
docker-compose --compatibility logs --follow --tail="100"

docker-compose --compatibility -f docker-compose.yml logs --follow --tail="100"
```
or using helper :

```bash
./aloes.sh -c log

./aloes.sh -c log -e production

./aloes.sh -c log -e local -s proxy
```

## TODO

- Replicate Mongo and Redis servers

- Use docker swarm to deploy on several machines

- Use aloes.sh to configure dynamically docker-compose services ?

