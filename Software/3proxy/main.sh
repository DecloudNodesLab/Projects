#!/bin bash
apt-get install -y wget make build-essential git nginx
service nginx start
git clone https://github.com/3proxy/3proxy.git
cd 3proxy
make -f Makefile.Linux
cp ./bin/3proxy /usr/bin
wget -O /usr/bin/3proxy.cfg https://raw.githubusercontent.com/DecloudNodesLab/Projects/main/Software/3proxy/3proxy.cfg
IP=$(wget -qO- eth0.me)
cat > /var/www/html/proxy.pac << EOF
function  FindProxyForURL  ( url ,  host )  { 
  // наши локальные URL из доменов ниже example.com не нуждаются в прокси: 
  if  ( shExpMatch ( host ,  '*.slack.com*.telegram.org;*.discord.com;*.ru' ))  {
    return 'DIRECT';
  }
  // All other requests go through port 8080 of proxy.example.com.
  // should that fail to respond, go directly to the WWW:
  return 'PROXY $IP:$PORT; DIRECT';
}
EOF

3proxy /usr/bin/3proxy.cfg
