#!/bin/bash
TZ=Europe/London && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
if [[ -z $MNEMONIC ]] || [[ -z $CONFIG_LINK ]] || [[ -z $BINARY_LINK ]] || [[ -z $GEOLOCATION ]] || [[ -z $IP ]] || [[ -z $RPC ]]
then 
echo Service stopped! Check env MNEMONIC, CONFIG_LINK, BINARY_LINK, GEOLOCATION and IP in your SDL!
sleep infinity
fi
apt-get install -y runit wget
runsvdir -P /etc/service &
if [[ -n $SSH_PASS ]]; then apt install ssh -y; echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && (echo $SSH_PASS; echo $SSH_PASS) | passwd root && service ssh restart; fi
wget -O /usr/bin/lavad $BINARY_LINK 
chmod +x /usr/bin/lavad
(echo $MNEMONIC)|lavad keys add wallet --recover --keyring-backend test
wget -O /root/rpcprovider.yml $CONFIG_LINK 
ADDRESS=`lavad keys show wallet  -a --keyring-backend test`
sleep 5
mkdir -p /root/lavap/log    
cat > /root/lavap/run <<EOF 
#!/bin/bash
exec 2>&1
exec lavad rpcprovider --geolocation $GEOLOCATION --from $ADDRESS --keyring-backend test --node $RPC
EOF
mkdir -p /tmp/lavap/log/
cat > /root/lavap/log/run <<EOF 
#!/bin/bash
exec svlogd -tt /tmp/lavap/log/
EOF
chmod +x /root/lavap/log/run /root/lavap/run 
ln -s /root/lavap /etc/service && ln -s /tmp/lavap/log/current /LOG_PROV
sleep 20
while true ; do tail -f /LOG_PROV ; done
