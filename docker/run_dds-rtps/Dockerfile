FROM ubuntu:24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y upgrade
RUN apt-get install --fix-missing -y git build-essential python3 pip python3-venv
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /opt
ADD "entrypoint.sh" .
RUN chmod +x entrypoint.sh

RUN git clone https://github.com/omg-dds/dds-rtps.git
RUN cd dds-rtps \
    && python3 -m venv .venv \
    && . .venv/bin/activate \
    && pip install -r requirements.txt

ENTRYPOINT ["/opt/entrypoint.sh"]
