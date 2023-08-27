FROM ubuntu:22.04
LABEL maintainer="decloudlab@gmail.com"
LABEL description="Decloud Nodes Lab"
LABEL site="https://declab.pro"
LABEL version="v5.4.0"
# Install necessary packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt install -y wget unzip && \
    rm -rf /var/lib/apt/lists/*
# Install applicaton
RUN mkdir /root/v2ray && \
    wget https://github.com/v2fly/v2ray-core/releases/download/v5.4.0/v2ray-linux-64.zip && \
    unzip ./v2ray-linux-64.zip -d /root/v2ray && \
    rm ./v2ray-linux-64.zip
COPY ./run.sh /
RUN sed -i 's/\r//' /run.sh && chmod +x /run.sh
# Run v2ray
CMD ["/run.sh"]
