#!/bin/bash
set -e

python3 gen_conf.py
bash get-certs.sh

/etc/init.d/haproxy start

while true; do
  sleep 86400 # 1 day
  certbot renew --standalone
done

