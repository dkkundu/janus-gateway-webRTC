FROM ubuntu:20.04

# Set environment variables to avoid interaction during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    autoconf \
    automake \
    bison \
    build-essential \
    clang \
    cmake \
    git \
    libtool \
    pkg-config \
    libssl-dev \
    libsrtp2-dev \
    libusrsctp-dev \
    libcurl4-openssl-dev \
    libjansson-dev \
    libmicrohttpd-dev \
    libopus-dev \
    libogg-dev \
    liblua5.3-dev \
    libavformat-dev \
    libavcodec-dev \
    libavutil-dev \
    libswscale-dev \
    libx264-dev \
    libssl-dev \
    curl \
    && apt-get clean

# Clone Janus Gateway source
RUN git clone --branch master --single-branch https://github.com/meetecho/janus-gateway.git /opt/janus

# Build Janus Gateway
WORKDIR /opt/janus
RUN sh autogen.sh && ./configure && make && make install

# Clean up unnecessary packages
RUN apt-get remove --purge -y \
    autoconf \
    automake \
    build-essential \
    clang \
    cmake \
    git \
    libtool \
    pkg-config \
    && apt-get clean

# Expose necessary ports
EXPOSE 8088 8188 10000-30000/udp

# Set the entrypoint
CMD ["/opt/janus/bin/janus", "--stun-server=stun.l.google.com:19302", "--rtp-port-range=10000-30000"]
