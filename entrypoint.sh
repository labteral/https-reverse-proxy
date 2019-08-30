#!/bin/bash
set -e

mkdir -p /etc/haproxy/ssl
python3 gen_conf.py
bash get-certs.sh

/etc/init.d/haproxy start

while true; do
  sleep 604800 # 7 days
  certbot renew --standalone
done
