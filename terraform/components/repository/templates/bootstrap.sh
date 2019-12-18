#!/bin/bash

apt-get install -y awscli jq debmirror apache2 dpkg-dev

hostname repository

sudo mkdir /home/mirrorkeyring
gpg --no-default-keyring --keyring /home/mirrorkeyring/trustedkeys.gpg --import /usr/share/keyrings/ubuntu-archive-keyring.gpg

export HOME=/home/ubuntu

# /srv/mirror.sh
echo "Skipping mirroring today"

a2dissite 000-default

cat << EOF > /etc/apache2/sites-available/001-mirror.conf
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www
    <Directory />
      Options FollowSymLinks Indexes
    </Directory>
</VirtualHost>
# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
EOF
a2ensite 001-mirror.conf

ln -s /data/mirror /var/www/ubuntu

service apache2 reload

mkdir /var/www/ubuntu/amd64

# sed -i 's@deb http://eu-west-2.ec2.archive.ubuntu.com/ubuntu/@deb http://localhost/ubuntu@g' /etc/apt/sources.list
cat <<EOF >> /etc/apt/sources.list.d/repository.list
deb [trusted=yes] http://${mirror_url}/ubuntu amd64/
EOF
