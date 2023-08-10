FROM ubuntu:22.04
RUN apt-get update && apt-get upgrade -y && apt-get install -y wget
COPY ./run.sh /
RUN sed -i 's/\r$//' /run.sh
ENTRYPOINT ["bash", "/run.sh"]
