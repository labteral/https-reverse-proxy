#!/bin/bash
source env.sh
docker rm -f reverse-proxy
docker run -d --net=host \
-e LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL \
-v "$CERTS_DIR":/etc/letsencrypt \
-v "$(pwd)"/domains.yaml:/opt/reverse-proxy/domains.yaml:ro \
-v "$(pwd)"/haproxy.yaml:/opt/reverse-proxy/haproxy.yaml:ro \
--name reverse-proxy \
$DOCKER_IMAGE
