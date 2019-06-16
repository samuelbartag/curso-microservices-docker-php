FROM php:7.2-fpm-alpine
LABEL maintainer="Samuel Bartag <samuel@samuelbartag.com.br>"


WORKDIR /var/www
RUN rm -rf /var/www/html

# Install packages
RUN apk add --no-cache --update --virtual buildDeps \
    autoconf \
    bash \
    nano \
    wget \
    curl \
    git \
    g++ \
    make \
    mysql-client \
    supervisor

RUN docker-php-ext-install pdo pdo_mysql
RUN pecl channel-update pecl.php.net \
    && pecl install redis \
    && docker-php-ext-enable redis

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Get access to FPM_Status page /status
RUN sed -i '/^;pm\.status_path/s/^;//' /usr/local/etc/php-fpm.d/www.conf

# Add configuration files
COPY conf/supervisord.conf /etc/

RUN ln -s public html

VOLUME ["/var/www", "/var/log/php"]

EXPOSE 9000

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
