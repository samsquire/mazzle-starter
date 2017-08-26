#!/bin/bash

echo """
UK
Kent
Rainham
VVV
laptop-backup.devops-pipeline.com
sam@samsquire.com
""" | openssl req -sha256 -newkey rsa:2048 -days 3650 -x509 -nodes -out root.cer -keyout root-key.pem

sudo touch /data/vault/ca/database.txt
echo 0000 | sudo tee /data/vault/ca/serialfile
sudo touch /data/vault/ca/certindex

