version: '2.0'
endpoints:
 lava:
   kind: ip
services:
  provider:
    image: dimokus88/lavaprovider:0.2
    env:
      - "SSH_PASS=YOUR_SSH_PASSWORD"
      - "MNEMONIC_BASE64="
      - "CONFIG_LINK="
      - "LAVAD_NODE="
      - "CHAIN_ID=lava-testnet-1"
      - "BINARY_LINK=https://github.com/lavanet/lava/releases/download/v0.16.0/lavad-v0.16.0-linux-amd64"
      - "IP="
      - "LAVAD_GEOLOCATION="
    expose:
      - port: 22
        to:
          - global: true
      - port: 12345
        to:
          - global: true
            ip: lava  
profiles:
  compute:
    provider:
      resources:
        cpu:
          units: 1
        memory:
          size: 2Gi
        storage:
          size: 10Gi
  placement:
    akash:
      pricing:
        provider:
          denom: uakt
          amount: 10000
deployment:
  provider:
    akash:
      profile: provider
      count: 1
