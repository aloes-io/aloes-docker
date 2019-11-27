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
    # echo "Stopping aloes-proxy for production"
    docker stop aloes-gw-prod
elif [ "${ENV}" == "local" ]
then
    FILENAME="docker-compose.yml"
    # echo "Stopping aloes-proxy"
    docker stop aloes-gw
else
    ENV="local"
    FILENAME="docker-compose.yml"
    # echo "Stopping aloes-proxy"
    docker stop aloes-gw
fi

echo "Stop ${ENV} containers"
docker-compose --compatibility -f ${FILENAME} down

if [ $? -ne 0 ]; then
    echo "Docker-compose stopped containers"
fi
