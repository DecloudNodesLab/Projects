version: '2.0'
endpoints:
 YOUR_ENDPOINT_NAME:
   kind: ip
services:
  basic-ubuntu:
    image: ubuntu:22.04
    env:
      - "MNEMONIC="
      - "CONFIG_LINK="
    command:
      - "bash"
      - '-c'
    args:
      - 'apt update && apt upgrade -y; apt install -y curl; curl -s https://raw.githubusercontent.com/DecloudNodesLab/Projects/main/CosmosSDK/Testnets/Lava/provider.sh | bash; sleep infinity'
    expose:
      - port: 22
        to:
          - global: true
      - port: 12345
        as: 12345
        to:
          - global: true
            ip: YOUR_ENDPOINT_NAME
profiles:
  compute:
    basic-ubuntu:
      resources:
        cpu:
          units: 2
        memory:
          size: 4Gi
        storage:
          size: 20Gi
  placement:
    akash:
      pricing:
        basic-ubuntu:
          denom: uakt
          amount: 10000
deployment:
  basic-ubuntu:
    akash:
      profile: basic-ubuntu
      count: 1
