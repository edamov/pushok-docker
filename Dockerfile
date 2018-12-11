FROM alpine:edge

MAINTAINER Arthur Edamov <edamov@gmail.com>

# Tutorial is here https://nathanleclaire.com/blog/2016/08/11/curl-with-http2-support---a-minimal-alpine-based-docker-image/

ENV CURL_VERSION 7.62.0
ENV XDEBUG_VERSION 2.6.1
# 1.8.0
ENV COMPOSER_VERSION_HASH d3e09029468023aa4e9dcd165e9b6f43df0a9999

RUN apk add --update --no-cache openssl openssl-dev nghttp2-dev ca-certificates

RUN apk add --update --no-cache \
        php7 \
        php7-curl \
        php7-dom \
        php7-gmp \
        php7-intl \
        php7-json \
        php7-mbstring \
        php7-openssl \
        php7-phar \
        php7-simplexml \
        php7-tokenizer \
        php7-xdebug \
        php7-xml \
        php7-xmlwriter

RUN apk add --update --no-cache --virtual curldeps g++ make perl && \
    wget https://curl.haxx.se/download/curl-$CURL_VERSION.tar.bz2 && \
    tar xjvf curl-$CURL_VERSION.tar.bz2 && \
    rm curl-$CURL_VERSION.tar.bz2 && \
    cd curl-$CURL_VERSION && \
    ./configure \
        --with-nghttp2=/usr \
        --prefix=/usr \
        --with-ssl \
        --enable-ipv6 \
        --enable-unix-sockets \
        --without-libidn \
        --disable-static \
        --disable-ldap \
        --with-pic && \
    make && \
    make install

RUN apk add --update --no-cache \
        apache-ant \
        autoconf \
        gcc \
        git \
        php7-dev \
        php7-pear \
        openssh \
        supervisor \
        wget \
        zip && \
    cd /tmp && \
    wget http://xdebug.org/files/xdebug-$XDEBUG_VERSION.tgz && \
    tar -zxvf xdebug-$XDEBUG_VERSION.tgz && \
    rm xdebug-$XDEBUG_VERSION.tgz && \
    cd xdebug-$XDEBUG_VERSION/ && \
    phpize && \
    ./configure --enable-xdebug && \
    make && \
    make install && \
    HOST_IP="$(/sbin/ip route|awk '/default/ { print $3 }')" && \
    sed -i "$ a\xdebug.remote_host=${HOST_IP}" /etc/php7/conf.d/xdebug.ini && \
    sed -i "$ a\zend_extension=xdebug.so" /etc/php7/conf.d/xdebug.ini

#Install composer
RUN cd / && \
    wget https://raw.githubusercontent.com/composer/getcomposer.org/$COMPOSER_VERSION_HASH/web/installer -O composer-setup.php && \
    php composer-setup.php && \
    rm composer-setup.php && \
    rm -r curl-$CURL_VERSION && \
    rm -r /var/cache/apk && \
    rm -r /usr/share/man && \
    apk del curldeps

CMD ["php", "-a"]
