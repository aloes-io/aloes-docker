#!/bin/bash

while [[ $# > 1 ]]
do
key="$1"

case $key in
    -e|--env)
        ENV="$2"
        shift # past argument
        ;;
    -s|--service)
        SERVICE="$2"
        shift # past argument
        ;;
    *)
    	usage
	    exit 1
    	;;
esac
shift # past argument or value
done

if [ "${ENV}" == "production" ]
then
    FILENAME="docker-compose.prod.yml"
    docker build -t aloes-gw-prod -f config/nginx/gw-dockerfile-production ./config/nginx
elif [ "${ENV}" == "local" ]
then
    FILENAME="docker-compose.yml"
    docker build -t aloes-gw -f config/nginx/gw-dockerfile ./config/nginx
else
    ENV="local"
    FILENAME="docker-compose.yml"
    docker build -t aloes-gw -f config/nginx/gw-dockerfile ./config/nginx
fi

echo "Build ${ENV} containers"

docker-compose --compatibility -f ${FILENAME} build

if [ $? -ne 0 ]; then
    echo "Docker-compose did not build container(s)"
fi
