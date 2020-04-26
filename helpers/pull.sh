#!/bin/bash

pull () {
  if [ -z "$1" ]; then
    echo "Environment name is required to pull containers images"
    exit 1
  fi

  local ENV=$1
  local SERVICE=$2
  local config="$(pwd)/.env"
  if [ ! -f "$config" ]; then
    echo "No environment file found, start by creating one"
    exit 1
  fi

  local compose_file="$(pwd)/docker-compose.yml"
  # if [ "$ENV" == "production" ]; then
  #   compose_file="$(pwd)/docker-compose.prod.yml"
  # fi

  a=$SECONDS
  echo "Pull $compose_file images"
  docker-compose --compatibility -f ${compose_file} pull &
  process_id=$!
  wait $process_id
  elapsedseconds=$(( SECONDS - a ))
  echo "Pulled images with status $? in $elapsedseconds s"
}