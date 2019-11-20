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

- Create `.env.local` and/or `.env` at root 

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

## Build

```bash
docker-compose --compatibility build 

docker-compose --compatibility -f docker-compose.prod.yml build 

docker-compose  -f docker-compose.prod.yml build <service_name>

docker-compose  -f docker-compose.prod.yml --no-deps --build <service_name> up
```

## Start

```bash
docker-compose --compatibility up 

docker-compose --compatibility -f docker-compose.prod.yml up -d
```

## Stop

```bash
docker-compose -f docker-compose.prod.yml down
```

## Monitor

```bash
docker-compose logs --tail="100"

docker-compose --compatibility -f docker-compose.prod.yml logs --follow --tail="100"
```
