#!/bin/bash
counter=0
while ! mount | grep /data/vault > /dev/null ; do
  echo "/data/vault does not exist yet, sleeping..."
  sleep 10
  counter=$((counter + 1))
  if [ $counter -ge 20 ] ; then
    break
  fi
done

ca_dir=/data/vault/ca
if [ ! -d "$ca_dir" ] ; then
  echo "Certificate directory does not exist, creating root ca"
  mkdir -p $ca_dir/certs
  cd $ca_dir
  sudo /srv/create_root_ca.sh ${vvv_env} ${domain}
  echo "Creating certificate for vault server"
  sudo /srv/create_certificate.sh vault.${vvv_env}.${domain}
fi

sudo systemctl enable vault.service
sudo service vault start
