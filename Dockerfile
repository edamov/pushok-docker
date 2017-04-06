FROM ubuntu:xenial

MAINTAINER Arthur Edamov <edamov@edamov.com>

RUN apt-get update && apt-get install -y g++ make binutils autoconf automake autotools-dev libtool pkg-config \
    zlib1g-dev libcunit1-dev libssl-dev libxml2-dev libev-dev libevent-dev libjansson-dev \
    libjemalloc-dev cython python3-dev python-setuptools git && \

    # Build nghttp2 from source
    git clone https://github.com/tatsuhiro-t/nghttp2.git && \
    cd nghttp2 && \
    autoreconf -i && \
    automake && \
    autoconf && \
    ./configure && \
    make && \
    make install && \

    #Install  curl
    cd ~ && \
    apt-get build-dep curl -y && \
    wget http://curl.haxx.se/download/curl-7.46.0.tar.bz2 && \
    tar -xvjf curl-7.46.0.tar.bz2 && \
    cd curl-7.46.0 && \
    ./configure --with-nghttp2=/usr/local --with-ssl && \
    make && \
    make install && \
    ldconfig && \
  
    curl --http2 -I nghttp2.org
  
CMD ["php", "-a"]
