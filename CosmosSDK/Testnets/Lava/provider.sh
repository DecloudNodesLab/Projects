#!/bin/bash
if [[ -z $MNEMONIC ]] || [[ -z $CONFIG_LINK ]] || [[ -z $BINARY_LINK ]] || [[ -z $GEOLOCATION ]] ; then echo Service stopped! Check env MNEMONIC, CONFIG_LINK, BINARY_LINK and GEOLOCATION in your SDL! ; fi
if [[ -n $SSH_PASS ]]; then apt install ssh -y; echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && (echo $SSH_PASS; echo $SSH_PASS) | passwd root && service ssh restart; fi
wget -O /usr/bin/lavad $BINARY_LINK;
(echo $MNEMONIC)|lavad keys add wallet --recover --keyring-backend test
wget -O /root/.lava/config/rpcprovider.yml $CONFIG_LINK 
lavad rpcprovider /root/.lava/config/rpcprovider.yml --geolocation $GEOLOCATION --from wallet --keyring-backend test;
