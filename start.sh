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
    docker run --rm -itd --name aloes-gw-prod -v "$(pwd)"/config/certbot/www:/var/www/certbot -v "$(pwd)"/config/certbot/conf:/etc/letsencrypt --net="host" aloes-gw-prod
elif [ "${ENV}" == "local" ]
then
    FILENAME="docker-compose.yml"
    docker run --rm -itd --name aloes-gw -v "$(pwd)"/config/certbot/www:/var/www/certbot --net="host" aloes-gw
else
    ENV="local"
    FILENAME="docker-compose.yml"
    docker run --rm -itd --name aloes-gw -v "$(pwd)"/config/certbot/www:/var/www/certbot --net="host" aloes-gw
fi

echo "Start ${ENV} containers"

docker-compose --compatibility -f ${FILENAME} up -d 

# docker-compose --compatibility -f ${FILENAME} up -d ${SERVICE}

if [ $? -ne 0 ]; then
    echo "Docker-compose did not start container(s)"
fi
