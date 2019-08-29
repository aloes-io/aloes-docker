# Aloes docker

Compose every dependencies needed to get a fully working Aloes network

## Start

```bash
docker-compose --compatibility  build 
docker-compose --compatibility -f docker-compose.prod.yml build 
```

## Start

```bash
docker-compose --compatibility up 
docker-compose --compatibility -f docker-compose.prod.yml up
```

## Stop


```bash
docker-compose -f docker-compose.prod.yml down
```