#!/bin/bash
TZ=Europe/London && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
if [[ -z $MNEMONIC ]] || [[ -z $CONFIG_LINK ]] || [[ -z $BINARY_LINK ]] || [[ -z $GEOLOCATION ]]
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
cp /root/.lava/data/priv_validator_state.json /root/.lava/priv_validator_state.json.backup && lavad tendermint unsafe-reset-all --keep-addr-book 
SIZE=`wget --spider $SNAPSHOT 2>&1 | awk '/Length/ {print $2}'`
echo == Download snapshot ==
(wget -nv -O - $SNAPSHOT | pv -petrafb -s $SIZE -i 5 | lz4 -dc - | tar -xf - -C /root/.lava) 2>&1 | stdbuf -o0 tr '\r' '\n'
echo == Complited ==
mv /root/.lava/priv_validator_state.json.backup /root/.lava/data/priv_validator_state.json && STATE_SYNC=off
fi
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" /root/.lava/config/config.toml
wget -O /root/.lava/config/rpcprovider.yml $CONFIG_LINK 
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
sleep 2m
lavad rpcprovider /root/.lava/config/rpcprovider.yml --geolocation $GEOLOCATION --from wallet --keyring-backend test;
