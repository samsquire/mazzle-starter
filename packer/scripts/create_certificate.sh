#!/bin/bash

domain=$1

echo """
UK
Kent
Rainham
VVV
$domain
sam@samsquire.com


""" | openssl req -newkey rsa:2048 -days 3650 -nodes -out $domain.csr -keyout $domain.privkey.pem

openssl ca -batch -config /srv/vault.conf -notext -in $domain.csr -out $domain.crt

