## Deploy Lava Provider

The launch is described using CloudFlare!

### Step 1
Deploy https://gitopia.com/DecloudNodesLab/cosmos-universe/tree/master/projects/Lava/lava_provider_deploy.yml , set  variables `SSH_PASS`, `MNEMONIC_BASE64`, `CONFIG_LINK`, `LAVAD_NODE` and `LAVAD_GEOLOCATION`.

Select provider. 

### Step 2 (CloudFlare)

Go to https://dash.cloudflare.com/ , select your domain name.

In left menu:

- Add "DNS" records TYPE-A,NAME-<subomain>, CONTENT-<YOUR_LEASE_IP_FROM_DEPLOY>

- Check "SSL/TLS-Overwiew", need select Full mode (not Full(strict)).

- In "Network" enable "gRPS" connection.

### Step 3 (run rpcprovider)

After that, it will be convenient to connect to the node via **ssh**.

Run test command:

lavad test rpcprovider --from $ADDRESS --keyring-backend test --node $LAVAD_NODE --endpoints "<YOUR_SUBDOMAIN.DOMAIN>:443,<CHAIN>"

Example result:

Run stake command:

lavad tx pairing stake-provider "<CHAIN>" "<AMOUNT_STAKE>ulava" "lava.declab.pro:443,2" 2 --chain-id $CHAIN_ID --from $ADDRESS --provider-moniker <YOUR_MONIKER> --keyring-backend "test" --gas="auto" --gas-adjustment "1.5" --fees 50000ulava --node $LAVAD_NODE -y


____

Decloud Nodes Lab

Professional decentralized validator powered by Akash Network.

Site: https://declab.pro

E-mail: decloudlab@gmail.com

Discord: https://discord.gg/rPENzerwZ8
