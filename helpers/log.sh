#!/bin/bash

log() {
  if ! [ -x "$(command -v docker-compose)" ]; then
    echo 'Error: docker-compose is not installed.' >&2
    exit 1
  fi
  if [ -z "$1" ]; then
    echo "Environment name is required"
    exit 1
  fi

  local ENV=$1
  local SERVICE=$2
  local config="$(pwd)/.env"
  if [ ! -f "$config" ]; then
    echo "No environment file found, start by creating one"
    exit 1
  fi

  # get servicename from $2
  if [ "$SERVICE" == "proxy" ]; then
    docker logs aloes-gw --follow --tail="100"
    # docker logs aloes-gw-prod --follow --tail="100"
  else
    local compose_file="$(pwd)/docker-compose.yml"
    if [ "$ENV" == "production" ]; then
      compose_file="$(pwd)/docker-compose-prod.yml"
    fi

    echo "Log $compose_file containers"
    docker-compose --compatibility -f $compose_file logs --follow --tail="100"

    if [ $? -ne 0 ]; then
      echo "Docker-compose cancelled logging"
    fi
  fi


}
