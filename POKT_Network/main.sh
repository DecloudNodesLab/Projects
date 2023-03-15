#!/bin/bash
TZ=Europe/Kiev && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
apt-get install -y wget gcc make git nvme-cli nano unzip runit
runsvdir -P /etc/service &
if [[ -n $SSH_PASS ]]
then
apt-get install -y ssh 
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
(echo $SSH_PASS; echo $SSH_PASS) | passwd root && service ssh restart
fi
wget https://go.dev/dl/go1.20.1.linux-amd64.tar.gz && tar -C /usr/local -xzf go1.20.1.linux-amd64.tar.gz
PATH=$PATH:/usr/local/go/bin && echo $PATH 
go version
echo 'export PATH='$PATH:/usr/local/go/bin >> /root/.bashrc
mkdir -p /root/.pocket/config
git clone https://github.com/pokt-network/pocket-core.git && cd pocket-core
git checkout tags/$VERSION
go build -o /usr/bin/pocket /pocket-core/app/cmd/pocket_core/main.go && pocket version
if [[ -n $KEYFILE_BASE64 ]]
then
echo $KEYFILE_BASE64 | base64 -d > /tmp/keyfile.json
apt-get install -y expect
cat > /root/import <<EOF
#!/usr/bin/expect -f
spawn pocket accounts import-armored /tmp/keyfile.json
expect {
"Enter decrypt pass" {
send "$KEY_PASS\n"
expect "Enter decrypt pass"
send "$KEY_PASS\n"
expect "$ADDRESS"
send "\n"
}
}
interact
EOF
sleep 5
echo Get access 1
chmod +x /root/import && /root/import
sleep 5
cat > /root/create_validator <<EOF
#!/usr/bin/expect -f
spawn pocket accounts set-validator $ADDRESS
expect {
"Enter the password:" {
send "$KEY_PASS\n"
}
}
interact
EOF
sleep 15
echo Get access 2
sleep 5
chmod +x /root/create_validator && /root/create_validator
echo Get access 3
sleep 5
fi
if [[ -n $CHAINS_LINK ]]
then
wget -O /root/.pocket/config/chains.json $CHAINS_LINK
fi
if [[ -n $CHAINS_BASE64 ]]
then
echo $CHAINS_BASE64 | base64 -d > /root/.pocket/config/chains.json
fi
echo Get access 4
sleep 2
curl -o $HOME/.pocket/config/genesis.json $GENESIS_LINK
sleep 2
if [[ -n $LINK_SNAPSHOT ]]
then
mkdir -p $HOME/.pocket/data
wget -qO- $LINK_SNAPSHOT | tar -xz -C $HOME/.pocket/data
fi
echo =Run node...= 
mkdir -p /root/pocket/log    
cat > /root/pocket/run <<EOF 
#!/bin/bash
exec 2>&1
exec pocket start --seeds="$SEEDS" --$CHAIN
EOF
mkdir /tmp/log/
cat > /root/pocket/log/run <<EOF 
#!/bin/bash
exec svlogd -tt /tmp/log/
EOF
chmod +x /root/pocket/log/run /root/pocket/run 
ln -s /root/pocket /etc/service && ln -s /tmp/log/current /LOG

sleep 20
for ((;;))
  do    
    tail -100 /LOG && sleep 5m
  done
fi
