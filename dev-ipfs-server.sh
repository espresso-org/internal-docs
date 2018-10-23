#!/usr/bin/env bash

#
# Installs and set up IPFS development server on port 64443
#


usage()
{
    echo "usage: dev-ipfs-server port "
}

if [ $# -lt 1 ]; then
    usage
    exit 1
fi



export IPFS_PATH=/mnt/disks/ipfs-data
wget https://dist.ipfs.io/go-ipfs/v0.4.17/go-ipfs_v0.4.17_linux-amd64.tar.gz
tar xvfz go-ipfs_v0.4.17_linux-amd64.tar.gz
cd go-ipfs
./install.sh
ipfs init --profile server
ipfs config Addresses.API /ip4/0.0.0.0/tcp/$1
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["*"]'

# Set up systemd daemon
cat <<EOT >> /etc/systemd/system/ipfs.service
[Unit]
Description=IPFS Daemon
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
Environment=IPFS_PATH=/mnt/disks/ipfs-data
ExecStart=/usr/local/bin/ipfs daemon --enable-namesys-pubsub

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable ipfs


echo "Type 'sudo systemctl start ipfs' to start the IPFS daemon on port 64443"
