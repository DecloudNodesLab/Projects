#!/bin/bash
TZ=Europe/London && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
if [[ -z $MNEMONIC ]] || [[ -z $CONFIG_LINK ]] || [[ -z $BINARY_LINK ]] || [[ -z $GEOLOCATION ]] || [[ -z $IP ]]
then 
echo Service stopped! Check env MNEMONIC, CONFIG_LINK, BINARY_LINK and GEOLOCATION in your SDL!
sleep infinity
fi
apt-get install -y tar lz4 pv runit wget
runsvdir -P /etc/service &
if [[ -n $SSH_PASS ]]; then apt install ssh -y; echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && (echo $SSH_PASS; echo $SSH_PASS) | passwd root && service ssh restart; fi
wget -O /usr/bin/lavad $BINARY_LINK 
chmod +x /usr/bin/lavad
(echo $MNEMONIC)|lavad keys add wallet --recover --keyring-backend test
wget -O /root/.lava/config/genesis.json https://snapshots.polkachu.com/testnet-genesis/lava/genesis.json
if [[ -n $SNAPSHOT ]]
then
lavad tendermint unsafe-reset-all --keep-addr-book 
SIZE=`wget --spider $SNAPSHOT 2>&1 | awk '/Length/ {print $2}'`
echo == Download snapshot ==
(wget -nv -O - $SNAPSHOT | pv -petrafb -s $SIZE -i 5 | lz4 -dc - | tar -xf - -C /root/.lava) 2>&1 | stdbuf -o0 tr '\r' '\n'
echo == Complited ==
fi
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" /root/.lava/config/config.toml
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ulava\"/;" /root/$FOLDER/config/app.toml
sed -i.bak -e "s/^enable = false/enable = true/;" /root/.lava/config/app.toml
wget -O /root/rpcprovider.yml $CONFIG_LINK 
mkdir -p /root/lavad/log    
cat > /root/lavad/run <<EOF 
#!/bin/bash
exec 2>&1
exec lavad start
EOF
mkdir /tmp/log/
cat > /root/lavad/log/run <<EOF 
#!/bin/bash
exec svlogd -tt /tmp/log/
EOF
chmod +x /root/lavad/log/run /root/lavad/run 
ln -s /root/lavad /etc/service && ln -s /tmp/log/current /LOG_NODE
sleep 1m
ADDRESS=`lavad keys show wallet  -a --keyring-backend test`
sleep 5
mkdir -p /root/lavap/log    
cat > /root/lavap/run <<EOF 
#!/bin/bash
exec 2>&1
exec lavad rpcprovider --geolocation $GEOLOCATION --from $ADDRESS --keyring-backend test --chain-id lava-testnet-1
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
