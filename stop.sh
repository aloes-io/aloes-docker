#!/bin/bash

docker-compose --compatibility down

# if prod arg
# docker-compose --compatibility -f docker-compose.prod.yml down