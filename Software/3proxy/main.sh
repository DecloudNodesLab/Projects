#!/bin bash
apt-get install -y sudo make build-essential git
git clone https://github.com/3proxy/3proxy.git
cd 3proxy
sudo make -f Makefile.Linux
cp ./bin/3proxy /usr/bin

cat > /usr/bin/3proxy.cfg << EOF
auth none
log
proxy -p80
EOF

3proxy /usr/bin/3proxy.cfg
