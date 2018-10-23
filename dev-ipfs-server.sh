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
ipfs config Addresses.API /ip4/127.0.0.1/tcp/64442
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


# Nginx reverse proxy config

apt install nginx
systemctl start nginx
systemctl enable nginx

cat <<EOT >> /etc/nginx/conf.d/nginx.conf
server {
  listen $1;
  listen [::]:$1;

  #server_name example.com;

  location / {
      proxy_pass http://localhost:64442/;
  }

  # Blocked paths
  location /api/v0/config/edit {}
  location /api/v0/config/profile {}
  location /api/v0/config/replace {}
  location /api/v0/files/rm {}
  location /api/v0/files/mv {}
}
EOT

nginx -s reload

###


echo "Type 'sudo systemctl start ipfs' to start the IPFS daemon on port 64443"
