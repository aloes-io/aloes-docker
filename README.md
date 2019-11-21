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

## Setup

- Create `.env` at root 

- Create `.env.local` and/or `.env` in `./config/device-manager/`

- Create `.env.local` and/or `.env` in `./config/mongo/`

- Create `.env.local` and/or `.env` in `./config/influxdb/`


If you intend to run in local mode ( no domain redirection ), you just have to configure environment variables and config files.

## Create HTTPS certificates

- First you either have to configure nginx to use a temporary config file located in `./config/nginx/nginx-tmp.template` or comment out ssl config from `./config/nginx/nginx-production.template` and start every services.

- Update `./config/certbot/letsencrypt-init.sh` with your domains and email and staging mode

```bash
chmod a+x config/certbot/letsencypt-init.sh 

sudo ./config/certbot/letsencrypt-init.sh

docker logs --tail 50 --follow aloes-docker_api-proxy_1
```

## Backup MongoDB

```bash
./config/mongo/mongodump.sh -db aloes_test -c aloes-docker_mongo_1 -u aloes --password example
```

## Restore MongoDB

```bash
./config/mongo/./mongorestore.sh -d aloes_test -db aloes_test -c aloes-docker_mongo_1 -u aloes -p example
```
## Display config

```bash
docker-compose config

docker-compose -f docker-compose.prod.yml config
```
or using shortcut :

```bash
./test-conf.sh

./test-conf.sh -e production
```

## Build

```bash
docker-compose --compatibility build 

docker-compose --compatibility -f docker-compose.prod.yml build 

docker-compose  -f docker-compose.prod.yml build <service_name>

docker-compose  -f docker-compose.prod.yml --no-deps --build <service_name> up
```
or using shortcut :

```bash
./build.sh

./build.sh -e production

./build.sh -e local -s <service_name>
```

## Start

```bash
docker-compose --compatibility up 

docker-compose --compatibility up -d

docker-compose --compatibility -f docker-compose.prod.yml up -d
```
or using shortcut :

```bash
./start.sh

./start.sh -e production

./start.sh -e local -s <service_name>
```


## Stop

```bash
docker-compose --compatibility down

docker-compose -f docker-compose.prod.yml down
```
or using shortcut :

```bash
./stop.sh

./stop.sh -e production

./stop.sh -e local -s <service_name>
```


## Monitor

```bash
docker-compose --compatibility logs --follow --tail="100"

docker-compose --compatibility -f docker-compose.prod.yml logs --follow --tail="100"
```
or using shortcut :

```bash
./log.sh

./log.sh -e production

./log.sh -e local -s <service_name>
```
