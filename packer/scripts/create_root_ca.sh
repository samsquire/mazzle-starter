#!/bin/bash
vvv_env=$1
domain=$2

echo """
UK
Kent
Rainham
VVV
${vvv_env}.${domain}
sam@samsquire.com
""" | openssl req -sha256 -newkey rsa:2048 -days 3650 -x509 -nodes -out root.cer -keyout root-key.pem

sudo touch /data/vault/ca/database.txt
echo 0000 | sudo tee /data/vault/ca/serialfile
sudo touch /data/vault/ca/certindex
