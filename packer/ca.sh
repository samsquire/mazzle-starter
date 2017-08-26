#!/bin/bash

create_root_ca=create_root_ca.sh
create_certificate=create_certificate.sh
vault_conf=vault.conf

sudo mv /tmp/$create_root_ca /srv/$create_root_ca
sudo mv /tmp/$create_certificate /srv/$create_certificate
sudo mv /tmp/$vault_conf /srv/$vault_conf

chmod +x /srv/$create_root_ca
chmod +x /srv/$create_certificate

