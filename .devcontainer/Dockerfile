FROM php:8.5-cli

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    curl \
    libzip-dev \
    libicu-dev \
    libsqlite3-dev \
    && docker-php-ext-install \
        intl \
        pdo \
        pdo_sqlite \
        zip \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY .devcontainer/php.dev.ini /usr/local/etc/php/conf.d/10-php-dev.ini
COPY .devcontainer/opcache.ini /usr/local/etc/php/conf.d/20-opcache.ini
COPY .devcontainer/xdebug.ini /usr/local/etc/php/conf.d/99-xdebug.ini
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /workspace