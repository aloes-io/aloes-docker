# Aloes docker

Compose every dependencies needed to get a fully working Aloes network

## Build

```bash
docker-compose --compatibility build 
docker-compose -p aloes-docker-prod --compatibility -f docker-compose.prod.yml build 
```

## Start

```bash
docker-compose --compatibility up 
docker-compose -p aloes-docker-prod --compatibility -f docker-compose.prod.yml up -d
```

## Stop

```bash
docker-compose -f docker-compose.prod.yml down
```

## Setup

If you intend to run in local mode ( no domain redirection ), you just have to configure environment variables and config files.

For domain name redirection with HTTPS server, configure and run `./config/certbot/letsencrypt-init.sh` 

## Monitor

```bash
docker-compose logs -f --tail="100"
```
