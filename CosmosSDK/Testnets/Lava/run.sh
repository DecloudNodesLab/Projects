#!/bin/bash
if [[ -z $MNEMONIC_BASE64 ]] || [[ -z $BINARY_LINK ]] || [[ -z $IP ]] || [[ -z $LAVAD_GEOLOCATION ]]
then 
echo Service stopped! Check env MNEMONIC_BASE64, BINARY_LINK, LAVAD_GEOLOCATION and IP in your SDL!
sleep infinity
fi
if [[ -n $SSH_PASS ]]; then apt install ssh -y; echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && (echo $SSH_PASS; echo $SSH_PASS) | passwd root && service ssh restart; fi
wget -O /usr/bin/lavad $BINARY_LINK 
chmod +x /usr/bin/lavad
lavad init "Lava Provider on Akash Network" --chain-id $CHAIN_ID
(echo $MNEMONIC_BASE64 | base64 -d )|lavad keys add wallet --recover --keyring-backend test
if [[ -n $CONFIG_LINK ]]; then wget -O /root/rpcprovider.yml $CONFIG_LINK ; fi
ADDRESS=`lavad keys show wallet  -a --keyring-backend test`
sleep 5
lavad rpcprovider --from $ADDRESS --keyring-backend test
