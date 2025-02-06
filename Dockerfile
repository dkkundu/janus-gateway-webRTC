FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

# Update package lists with retry logic
RUN apt-get update || (sleep 5 && apt-get update)

# Install necessary packages
RUN apt-get install -y \
    autoconf \
    automake \
    build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=noninteractive \
    JANUS_DIR=/opt/janus

RUN mkdir -p /opt/janus-config /opt/janus-data /opt/recordings /opt/plugins
RUN chmod -R 777 /opt/janus-data /opt/recordings
    

# Install necessary dependencies (including libsrtp2 runtime)
RUN apt-get update && apt-get install -y \
    autoconf \
    automake \
    bison \
    build-essential \
    clang \
    cmake \
    curl \
    git \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libconfig9 \
    libconfig-dev \
    libcurl4-openssl-dev \
    libglib2.0-dev \
    libjansson-dev \
    liblua5.3-dev \
    libmicrohttpd-dev \
    libnice10 \
    libnice-dev \
    libogg-dev \
    libopus-dev \
    libsofia-sip-ua-dev \
    libssl-dev \
    libsrtp2-1 \
    libsrtp2-dev \
    libswscale-dev \
    libtool \
    libusrsctp-dev \
    libwebsockets-dev \
    libx264-dev \
    pkg-config \
    zlib1g-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Clone Janus Gateway source
WORKDIR $JANUS_DIR
COPY . .

# Build Janus Gateway
RUN ./autogen.sh && \
    ./configure --prefix=$JANUS_DIR && \
    make && \
    make install && \
    make configs

# Clean up unnecessary packages (but keep runtime libraries)
RUN apt-get remove --purge -y \
    build-essential \
    clang \
    cmake \
    git \
    libtool \
    pkg-config \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Expose necessary ports
EXPOSE 8088 8188 10000-30000/udp

# Set the entrypoint
ENTRYPOINT ["/opt/janus/bin/janus"]

CMD ["--stun-server=stun.l.google.com:19302", "--rtp-port-range=10000-30000"]