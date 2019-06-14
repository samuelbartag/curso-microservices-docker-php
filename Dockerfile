FROM php:7.2-fpm-alpine
LABEL maintainer="Samuel Bartag <samuel@samuelbartag.com.br>"


WORKDIR /var/www

# Install packages
RUN apk --update add wget \
    curl \
    git \
    grep \
    build-base \
    libmemcached-dev \
    libmcrypt-dev \
    libxml2-dev \
    imagemagick-dev \
    pcre-dev \
    libtool \
    make \
    autoconf \
    g++ \
    cyrus-sasl-dev \
    libgsasl-dev \
    supervisor

RUN docker-php-ext-install mysqli mbstring pdo pdo_mysql tokenizer xml
RUN pecl channel-update pecl.php.net \
    && pecl install xdebug \
    && pecl install memcached \
    && pecl install imagick \
    && pecl install mcrypt-1.0.1 \
    && pecl install redis \
    && docker-php-ext-enable xdebug \
    && docker-php-ext-enable memcached \
    && docker-php-ext-enable imagick \
    && docker-php-ext-enable mcrypt \
    && docker-php-ext-enable redis

# Get access to FPM_Status page /status
RUN sed -i '/^;pm\.status_path/s/^;//' /usr/local/etc/php-fpm.d/www.conf

RUN rm /var/cache/apk/*

# Add configuration files
COPY conf/supervisord.conf /etc/
COPY conf/xdebug.ini /usr/local/etc/php/conf.d/xdebug-enabled.ini


VOLUME ["/var/www", "/var/log/php"]

EXPOSE 9000

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
