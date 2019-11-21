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
elif [ "${ENV}" == "local" ]
then
    FILENAME="docker-compose.yml"
else
    ENV="local"
    FILENAME="docker-compose.yml"
fi

echo "Log ${ENV} containers"
docker-compose --compatibility -f ${FILENAME} logs --follow --tail="100"

if [ $? -ne 0 ]; then
    echo "Docker-compose did not display logs"
fi
