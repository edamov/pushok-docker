FROM php:7-alpine

MAINTAINER Arthur Edamov <artur.edamov@edamov.com>

RUN apk --update add --no-cache git && \

  # Install nghttp2 and tools (C library for http2)
  sudo apt-get install g++ make binutils autoconf automake autotools-dev libtool pkg-config \
    zlib1g-dev libcunit1-dev libssl-dev libxml2-dev libev-dev libevent-dev libjansson-dev \
    libjemalloc-dev cython python3-dev python-setuptools
    
  # Build nghttp2 from source
  git clone https://github.com/tatsuhiro-t/nghttp2.git
  cd nghttp2
  autoreconf -i
  automake
  autoconf
  ./configure
  make
  sudo make install
  
  #Install  curl
  cd ~
  apk --update add --no-cache build-dep curl
  wget http://curl.haxx.se/download/curl-7.46.0.tar.bz2
  tar -xvjf curl-7.46.0.tar.bz2
  cd curl-7.46.0
  ./configure --with-nghttp2=/usr/local --with-ssl
  make
  sudo make install
  sudo ldconfig
  curl --http2 -I nghttp2.org
  
  docker-php-ext-install curl && \
  
  # Remove apk cache
  rm -rf /var/cache/apk/
  
CMD ["php", "-a"]
