FROM php:7-alpine

MAINTAINER Arthur Edamov <artur.edamov@edamov.com>

RUN apk --update add --no-cache grep openssh-client rsync && \
  
  #Install  curl
  docker-php-ext-configure gd \
    --with-gd \
    --with-freetype-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ && \
  docker-php-ext-install curl && \
  
  # Remove apk cache
  rm -rf /var/cache/apk/
  
CMD ["php", "-a"]
