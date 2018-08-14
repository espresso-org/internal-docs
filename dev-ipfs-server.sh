#!/usr/bin/env bash

#
# Installs and set up IPFS development server on port 64443
#

export IPFS_PATH=/path/to/ipfsrepo
wget https://dist.ipfs.io/go-ipfs/v0.4.17/go-ipfs_v0.4.17_linux-amd64.tar.gz
tar xvfz go-ipfs_v0.4.17_linux-amd64.tar.gz
cd go-ipfs
./install.sh
ipfs init
ipfs config Addresses.API /ip4/0.0.0.0/tcp/64443
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["*"]'
