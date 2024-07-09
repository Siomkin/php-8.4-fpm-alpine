FROM php:8.4.0alpha1-fpm-alpine

ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN apk update && apk upgrade

# Install dependencies
RUN apk add mariadb-client ca-certificates postgresql-dev libssh-dev zip libzip-dev libxml2-dev jpegoptim optipng pngquant gifsicle libxslt-dev rabbitmq-c-dev icu-dev oniguruma-dev gmp-dev

RUN apk add freetype-dev libjpeg-turbo-dev libpng-dev jpeg-dev libwebp-dev

RUN apk add supervisor bash curl unzip git

# RUN apk add --update linux-headers
# RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
#     && pecl install xdebug \
#     && docker-php-ext-enable xdebug \
#     && apk del -f .build-deps
RUN apk add --update linux-headers
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    # Manually download and install Xdebug compatible with PHP 8.4
    && mkdir -p /usr/src/php/ext/xdebug \
    && curl -fsSL https://xdebug.org/files/xdebug-3.4.0alpha1.tgz | tar xvz -C /usr/src/php/ext/xdebug --strip 1 \
    && docker-php-ext-install xdebug \
    && apk del -f .build-deps

# Install extensions
RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions zip opcache pdo_mysql pdo_pgsql mysqli bcmath sockets xsl exif intl gmp pcntl redis gd

#RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && docker-php-ext-install gd

WORKDIR /var/www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
