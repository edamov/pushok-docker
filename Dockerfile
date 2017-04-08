FROM alpine:edge

MAINTAINER Arthur Edamov <edamov@gmail.com>

# Tutorial is here https://nathanleclaire.com/blog/2016/08/11/curl-with-http2-support---a-minimal-alpine-based-docker-image/

# For nghttp2-dev, we need this respository.
RUN echo https://dl-cdn.alpinelinux.org/alpine/edge/testing >>/etc/apk/repositories

ENV CURL_VERSION 7.50.1
ENV XDEBUG_VERSION 2.5.1

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
    php -r "copy('http://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \

    rm -r curl-$CURL_VERSION && \
    rm -r /var/cache/apk && \
    rm -r /usr/share/man && \
    apk del curldeps

CMD ["php", "-a"]
