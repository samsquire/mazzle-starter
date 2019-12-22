#!/bin/bash
curl -L -O https://github.com/prometheus/node_exporter/releases/download/v0.14.0/node_exporter-0.14.0.linux-amd64.tar.gz
tar -xvzf node_exporter-0.14.0.linux-amd64.tar.gz

sudo mv node_exporter-0.14.0.linux-amd64/node_exporter /bin/

source /etc/os-release

if [ "$NAME" == "Ubuntu" ] ; then

cat << 'EOF' | sudo tee /etc/systemd/system/node_exporter.service > /dev/null
[Unit]
Description=node_exporter
Requires=network-online.target

[Service]
Type=simple
ExecStart=/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable node_exporter
sudo systemctl start node_exporter

else

cat << 'EOF' | sudo tee /etc/init/node_exporter.conf > /dev/null
#!upstart
description "node_exporter"
start on startup
stop on shutdown

respawn
exec /bin/node_exporter
EOF
sudo start node_exporter
fi

