# Telegram @Dimokus
# Discord Dimokus#1032
# 2023
#!/bin/bash
# Часть 1 Установка ПО
TZ=Europe/Kiev && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
if [[ -z $BINARY_LINK ]]
then
apt install -y nano tar wget lz4 zip jq runit build-essential git make gcc nvme-cli
else
apt install -y nano tar wget lz4 zip jq runit
fi
runsvdir -P /etc/service &
if [[ -z $GO_VERSION ]]
then
GO_VERSION="1.20.1"
fi
wget https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz && tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz
PATH=$PATH:/usr/local/go/bin
echo $PATH
go version
sleep 2
echo 'export PATH='$PATH:/usr/local/go/bin >> /root/.bashrc
if [[ -n $SSH_PASS ]] # Если задана переменная SSH_PASS - включаем службу SSH
then 
apt install -y ssh
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && (echo ${SSH_PASS}; echo ${SSH_PASS}) | passwd root && service ssh restart
fi
if [[ -n $SSH_KEY ]]
then
apt install -y ssh
echo $SSH_KEY > /root/.ssh/authorized_keys
chmod 0600 /root/.ssh/authorized_keys
service ssh restart
fi

# Часть 2 Переменные

if [[ -n $RPC ]]
then
	if [[ -z $CHAIN ]]
	then
		CHAIN=`curl -s $RPC/status | jq -r .result.node_info.network`
	fi
	if [[ -z $BINARY_VERSION ]]
	then
		BINARY_VERSION=`curl -s $RPC/abci_info | jq -r .result.response.version`
	fi
fi
echo 'export MONIKER='${MONIKER} >> /root/.bashrc
echo 'export BINARY_VERSION='${BINARY_VERSION} >> /root/.bashrc
echo 'export CHAIN='${CHAIN} >> /root/.bashrc
echo 'export RPC='${RPC} >> /root/.bashrc
echo 'export GENESIS='${GENESIS} >> /root/.bashrc
# Часть 3 Компиляция
if [[ -n $BINARY_LINK ]]
then
	if echo $BINARY_LINK | grep tar
	then
		wget -O /tmp/$BINARY.tar.gz $BINARY_LINK && tar -xvf /tmp/$BINARY.tar.gz -C /usr/bin/
	else
		wget -O /usr/bin/$BINARY $BINARY_LINK
	fi
else
	GIT_FOLDER=`basename $GITHUB_REPOSITORY | sed "s/.git//"`
	git clone $GITHUB_REPOSITORY && cd $GIT_FOLDER && git checkout $BINARY_VERSION && make build && make install
	BINARY=`ls /root/go/bin`
	if [[ -z $BINARY ]]
	then
		BINARY=`ls /root/$GIT_FOLDER/build/` && cp /root/$GIT_FOLDER/build/$BINARY /usr/bin/$BINARY
	else
		cp /root/go/bin/$BINARY /usr/bin/$BINARY
	fi
fi
sleep 3
chmod +x /usr/bin/$BINARY
echo $BINARY && echo 'export BINARY='${BINARY} >> /root/.bashrc && $BINARY version

# Часть 4 Конфигурирование
$BINARY init "$MONIKER" --chain-id $CHAIN  && sleep 5 

if [[ -z $FOLDER ]]
then
FOLDER=.`echo $BINARY | sed "s/d$//"`
fi

if [[ -n ${RPC} ]] && [[ -z ${GENESIS} ]]
then 
	rm /root/$FOLDER/config/genesis.json
	curl -s $RPC/genesis | jq .result.genesis >> /root/$FOLDER/config/genesis.json
	if [[ -z $DENOM ]]
	then
		DENOM=`curl -s $RPC/genesis | grep denom -m 1 | tr -d \"\, | sed "s/denom://" | tr -d \ ` && 	echo 'export DENOM='${DENOM} >> /root/.bashrc
	fi
fi
if [[ -n $GENESIS ]]
then	
	if echo $GENESIS | grep tar
	then
		rm /root/$FOLDER/config/genesis.json && mkdir /tmp/genesis/
		wget -O /tmp/genesis.tar.gz $GENESIS && tar -C /tmp/genesis/ -xf /tmp/genesis.tar.gz
		rm /tmp/genesis.tar.gz && mv /tmp/genesis/`ls /tmp/genesis/` /root/$FOLDER/config/genesis.json		
		if [[ -z $DENOM ]]
		then
			DENOM=`curl -s $RPC/genesis | grep denom -m 1 | tr -d \"\, | sed "s/denom://" | tr -d \ ` && echo 'export DENOM='${DENOM} >> /root/.bashrc
		fi
	else
		rm /root/$FOLDER/config/genesis.json && wget -O /root/$FOLDER/config/genesis.json $GENESIS
		if [[ -z $DENOM ]]
		then
			DENOM=`curl -s $RPC/genesis | grep denom -m 1 | tr -d \"\, | sed "s/denom://" | tr -d \ ` && echo 'export DENOM='${DENOM} >> /root/.bashrc
		fi
	fi
fi
echo $DENOM
sleep 5
if [[ -n $SNAPSHOT ]]
then
echo == Download snapshot ==
echo = Скачивание снепшота =
cp /root/$FOLDER/data/priv_validator_state.json /root/$FOLDER/priv_validator_state.json.backup 
$BINARY tendermint unsafe-reset-all --keep-addr-book 
curl $SNAPSHOT | lz4 -dc - | tar -xf - -C /root/$FOLDER
echo == Complited ==
echo == Завершено ==
mv /root/$FOLDER/priv_validator_state.json.backup /root/$FOLDER/data/priv_validator_state.json
STATE_SYNC=off
fi
if [[ -n ${RPC} ]] && [[  -z "$PEERS" ]]
then
  n_peers=`curl -s $RPC/net_info? | jq -r .result.n_peers` && let n_peers="$n_peers"-1
  RPC="$RPC" && echo -n "$RPC," >> /tmp/RPC.txt
  p=0 && count=0 && echo "Search peers..."
  while [[ "$p" -le  "$n_peers" ]] && [[ "$count" -le 9 ]]
  do
	  PEER=`curl -s  $RPC/net_info? | jq -r .result.peers["$p"].node_info.listen_addr`
    if echo $PEER | grep tcp
    then
    	count="$count"+1
    else
    	id=`curl -s  $RPC/net_info? | jq -r .result.peers["$p"].node_info.id` && echo -n "$id@$PEER," >> /tmp/PEERS.txt
	echo $id@$PEER && echo $PEER | sed 's/:/ /g' > /tmp/addr.tmp
	ADDRESS=(`cat /tmp/addr.tmp`) && ADDRESS=`echo ${ADDRESS[0]}`
	PORT=(`cat /tmp/addr.tmp`) && PORT=`echo ${PORT[1]}` && count="$count"+1
   fi
   p="$p"+1
done
echo "Search peers is complete!" && PEERS=`cat /tmp/PEERS.txt | sed 's/,$//'`
fi
echo $PEERS && echo $SEEDS
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025$DENOM\"/;" /root/$FOLDER/config/app.toml
sed -i.bak -e "s/^double_sign_check_height *=.*/double_sign_check_height = 15/;" /root/$FOLDER/config/config.toml
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/;" /root/$FOLDER/config/config.toml
sed -i.bak -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|;" /root/$FOLDER/config/config.toml
sed -i.bak -e "s/^flush_throttle_timeout *=.*/flush_throttle_timeout = \"50ms\"/;" /root/$FOLDER/config/config.toml
sed -i.bak -e "s_"tcp://127.0.0.1:26656"_"tcp://0.0.0.0:26656"_;" /root/$FOLDER/config/config.toml
if [[ -z $DISABLE_RPC ]]
then
sed -i.bak -e "s_"tcp://127.0.0.1:26657"_"tcp://0.0.0.0:26657"_;" /root/$FOLDER/config/config.toml
fi
if [[ -z $PRUNING ]]
then
	if [[ -z $KEEP_RECENT ]] || [[ -z $INTERVAL ]]
	then
	KEEP_RECENT=1000 && INTERVAL=10
	fi
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" /root/$FOLDER/config/app.toml && \
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$KEEP_RECENT\"/" /root/$FOLDER/config/app.toml && \
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$INTERVAL\"/" /root/$FOLDER/config/app.toml
fi
if [[ -n $SNAPSHOT_INTERVAL ]]
then
sed -i.bak -e "s/^snapshot-interval *=.*/snapshot-interval = \"$SNAPSHOT_INTERVAL\"/" /root/$FOLDER/config/app.toml
fi
# ====================RPC======================
if [[ -n ${RPC} ]] && [[ -z $STATE_SYNC ]]
then
	
	LATEST_HEIGHT=`curl -s $RPC/block | jq -r .result.block.header.height` 
	BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)) && BLOCK_HEIGHT=`echo $BLOCK_HEIGHT | sed "s/...$/000/"`
	TRUST_HASH=$(curl -s "$RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
	echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH
	RPC=`echo $RPC,$RPC` &&	echo $RPC
	sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
	s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$RPC\"| ; \
	s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
	s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" /root/$FOLDER/config/config.toml
fi
#================================================

if [[ -n ${VALIDATOR_KEY_JSON_BASE64} ]]
then
echo $VALIDATOR_KEY_JSON_BASE64 | base64 -d > /root/$FOLDER/config/priv_validator_key.json
fi

# Часть 5 Запуск
if [[ -n ${RPC} ]]
then
  HEX=`cat /root/$FOLDER/config/priv_validator_key.json | jq -r .address`
  COUNT=15 && CHECKING_BLOCK=`curl -s $RPC/abci_info? | jq -r .result.response.last_block_height`
  while [[ $COUNT -gt 0 ]]
  do
    CHEKER=`curl -s $RPC/commit?height=$CHECKING_BLOCK | grep $HEX`
    if [[ -n $CHEKER  ]]
    then
    	echo ++ Защита от двойной подписи!++
    	echo ++ ВНИМАНИЕ! ОБНАРУЖЕНА ПОДПИСЬ В ВАЛИДАТОРА НА БЛОКЕ № $CHECKING_BLOCK ! ЗАПУСК НОДЫ ОСТАНОВЛЕН! ++
    	echo ++ Double signature protection!++
    	echo ++ WARNING! VALIDATOR SIGNATURE DETECTED ON BLOCK № $CHECKING_BLOCK ! NODE LAUNCH HAS BEEN STOPPED! ++
    	sleep infinity
    fi
    let COUNT=$COUNT-1 && let CHECKING_BLOCK=$CHECKING_BLOCK-1 && sleep 1
  done
fi
echo =Run node...= 
mkdir -p /root/$BINARY/log    
cat > /root/$BINARY/run <<EOF 
#!/bin/bash
exec 2>&1
exec $BINARY start
EOF
mkdir /tmp/log/
cat > /root/$BINARY/log/run <<EOF 
#!/bin/bash
exec svlogd -tt /tmp/log/
EOF
chmod +x /root/$BINARY/log/run /root/$BINARY/run 
ln -s /root/$BINARY /etc/service && ln -s /tmp/log/current /LOG
sleep 20
for ((;;))
  do    
    tail -100 /LOG | grep -iv peer && sleep 10m
  done
fi
