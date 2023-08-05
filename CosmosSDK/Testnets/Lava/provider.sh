#!/bin/bash
if [[ -z $MNEMONIC ]] || [[ -z $CONFIG_LINK ]] || [[ -z $BINARY_LINK ]] || [[ -z $GEOLOCATION ]] ; then echo Service stopped! Check env MNEMONIC, CONFIG_LINK, BINARY_LINK and GEOLOCATION in your SDL! ; fi
apt install -y tar lz4 runit
if [[ -n $SSH_PASS ]]; then apt install ssh -y; echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && (echo $SSH_PASS; echo $SSH_PASS) | passwd root && service ssh restart; fi
wget -O /usr/bin/lavad $BINARY_LINK;
(echo $MNEMONIC)|lavad keys add wallet --recover --keyring-backend test
wget -O /root/.lava/config/genesis.json https://snapshots.polkachu.com/testnet-genesis/lava/genesis.json
SNAP_URL="http://snapshots.autostake.com/lava-testnet-1"
SNAP_NAME=$(curl -s $SNAP_URL/ | egrep -o ">lava-testnet-1.*.tar.lz4" | tr -d ">" | tail -1)
curl $SNAP_URL/$SNAP_NAME | lz4 -d | tar -xvf -
wget -O /root/.lava/config/rpcprovider.yml $CONFIG_LINK 
lavad rpcprovider /root/.lava/config/rpcprovider.yml --geolocation $GEOLOCATION --from wallet --keyring-backend test;
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
