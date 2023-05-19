#!/bin/bash
apt-get install -y make build-essential git
git clone https://github.com/3proxy/3proxy.git
cd 3proxy
make -f Makefile.Linux
cp ./bin/3proxy /usr/bin
curl -o /usr/bin/3proxy.cfg https://raw.githubusercontent.com/DecloudNodesLab/Projects/main/Software/3proxy/3proxy.cfg

3proxy /usr/bin/3proxy.cfg
