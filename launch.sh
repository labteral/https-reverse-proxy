#!/bin/bash
source env.sh
docker rm -f $CONTAINER_NAME 2> /dev/null
docker run -d --net=host \
-e LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL \
-v "$CERTS_DIR":/etc/letsencrypt \
-v "$(pwd)"/domains.yaml:/opt/reverse-proxy/domains.yaml:ro \
-v "$(pwd)"/haproxy.yaml:/opt/reverse-proxy/haproxy.yaml:ro \
--name $CONTAINER_NAME \
$DOCKER_IMAGE
