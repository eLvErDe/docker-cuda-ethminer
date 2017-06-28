FROM nvidia/cuda:8.0-devel

MAINTAINER Adam Cecile <acecile@le-vert.net>

ENV TERM xterm
ENV HOSTNAME ethminer.local

WORKDIR /root

# Upgrade base system
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y -o 'Dpkg::Options::=--force-confdef' -o 'Dpkg::Options::=--force-confold' dist-upgrade \
    && rm -rf /var/lib/apt/lists/*

# Install build dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y -o 'Dpkg::Options::=--force-confdef' -o 'Dpkg::Options::=--force-confold' install \
    git cmake \
    && rm -rf /var/lib/apt/lists/*

# Build ethminer
RUN git clone https://github.com/ethereum-mining/ethminer.git /root/src/ \
    && mkdir /root/build && cd /root/build \
    && cmake -DETHASHCUDA=ON -DETHASHCL=OFF -DETHSTRATUM=ON /root/src/ \
    && cmake --build /root/build/ \
    && mv /root/build/ethminer/ethminer /root/ethminer \
    && rm -rf /root/build /root/src/
