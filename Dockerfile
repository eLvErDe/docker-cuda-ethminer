FROM debian:stretch

MAINTAINER Adam Cecile <acecile@le-vert.net>

ENV TERM xterm
ENV HOSTNAME ethminer.local
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /root

# Upgrade base system
RUN apt-get update \
    && apt --yes dist-upgrade \
    && rm -rf /var/lib/apt/lists/*

# Install build dependencies
RUN apt update \
    && apt install --yes --no-install-recommends git cmake build-essential ca-certificates wget gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install CUDA 8 toolkit
RUN echo "deb http://deb.debian.org/debian stretch contrib non-free" >> /etc/apt/sources.list \
    && apt update \
    && apt install --yes --no-install-recommends nvidia-cuda-toolkit \
    && rm -rf /var/lib/apt/lists/*

# And my repository to have older GCC compatible with CUDA 8
RUN wget -O - https://packages.le-vert.net/packages.le-vert.net.gpg.key | apt-key add - \
    && echo "deb http://packages.le-vert.net/mining/debian stretch main" > /etc/apt/sources.list.d/packages_le_vert_net_mining.list \
    && apt update \
    && apt install --yes --no-install-recommends gcc-4.9 g++-4.9 \
    && rm -rf /var/lib/apt/lists/*

ENV CC=gcc-4.9
ENV CXX=g++-4.9

# Build ethminer
# See https://github.com/ethereum-mining/ethminer/blob/master/libethash-cuda/CMakeLists.txt
# Cannot use level 70 on CUDA 8
RUN git clone https://github.com/ethereum-mining/ethminer.git /root/src/ \
    && mkdir /root/build && cd /root/build \
    && sed -i '/"-gencode arch=compute_70,code=sm_70"/d' /root/src/libethash-cuda/CMakeLists.txt \
    && cmake -DETHASHCUDA=ON -DETHASHCL=OFF -DETHSTRATUM=ON -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON /root/src/ \
    && cmake --build /root/build/ \
    && mv /root/build/ethminer/ethminer /root/ethminer \
    && rm -rf /root/build /root/src/

# nvidia-container-runtime @ https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/8.0/runtime/Dockerfile
ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
LABEL com.nvidia.volumes.needed="nvidia_driver"
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
