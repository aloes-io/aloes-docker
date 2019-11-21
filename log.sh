#!/bin/bash

docker-compose --compatibility logs --follow --tail="100"

# if prod arg
# docker-compose --compatibility -f docker-compose.prod.yml logs --follow --tail="100"