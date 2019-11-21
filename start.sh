#!/bin/bash

docker-compose --compatibility up -d

# if prod arg
# docker-compose --compatibility -f docker-compose.prod.yml config