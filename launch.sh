#!/bin/bash
source env.sh
docker rm -f $CONTAINER_NAME 2> /dev/null
mkdir -p data; touch data/checksum
docker run -d --net=host \
-e LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL \
-v "$(pwd)"/domains.yaml:/opt/reverse-proxy/domains.yaml:ro \
-v "$(pwd)"/haproxy.yaml:/opt/reverse-proxy/haproxy.yaml:ro \
-v "$(pwd)"/data/letsencrypt:/etc/letsencrypt \
-v "$(pwd)"/data/checksum:/opt/reverse-proxy/get-certs.sh.sha1 \
--restart always \
--name $CONTAINER_NAME \
$DOCKER_IMAGE
