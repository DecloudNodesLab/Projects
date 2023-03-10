#!/bin/bash
apt-get install -y wget make build-essential git nginx
service nginx start 
git clone https://github.com/3proxy/3proxy.git
cd 3proxy
make -f Makefile.Linux
cp ./bin/3proxy /usr/bin
wget -O /usr/bin/3proxy.cfg https://raw.githubusercontent.com/DecloudNodesLab/Projects/main/Software/3proxy/3proxy.cfg
IP=`curl ifconfig.me`
sleep 3
cat > /var/www/html/wpad.dat << EOF
function  FindProxyForURL  ( url ,  host )  { 
if  ( shExpMatch ( host ,  '*.slack.com*.telegram.org;*.discord.com;*.ru;*.github.com;*.рф;*.google.com;*.youtube.com' ))  {
return 'DIRECT';
}
return 'PROXY $IP:$PORT; DIRECT';
}
EOF

3proxy /usr/bin/3proxy.cfg
