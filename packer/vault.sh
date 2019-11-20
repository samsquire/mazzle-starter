#!/bin/bash

vvv_env=$1
domain=$2

cat << EOF | sudo tee /srv/vault.hcl > /dev/null
storage "file" {
  path = "/srv/vault/data"
}
listener "tcp" {
 address = "0.0.0.0:8200"
 tls_cert_file = "/data/vault/ca/vault.${vvv_env}.${domain}.crt"
 tls_key_file = "/data/vault/ca/vault.${vvv_env}.${domain}.privkey.pem"
}
EOF

cat << EOF | sudo tee /etc/systemd/system/vault.service > /dev/null
[Unit]
Description=vault
After=volume.service
Requires=volume.service network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/vault server -config=/srv/vault.hcl

[Install]
WantedBy=multi-user.target
EOF
