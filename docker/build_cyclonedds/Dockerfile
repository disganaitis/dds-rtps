FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y upgrade
RUN apt-get install --fix-missing -y git cmake build-essential
RUN rm -rf /var/lib/apt/lists/*
	
WORKDIR /opt
ADD "entrypoint.sh" .
RUN chmod +x entrypoint.sh
RUN git clone https://github.com/eclipse-cyclonedds/cyclonedds.git cyclonedds
RUN git clone https://github.com/openssl/openssl.git openssl
RUN git clone https://github.com/disganaitis/dds-rtps.git dds-rtps
CMD ["bash", "./entrypoint.sh"]
