FROM php:7.4-apache

MAINTAINER Mia Metzler <docker@metzler.systems>

ARG MAPBENDER_VERSION
ENV MAPBENDER_URL https://mapbender.org/builds/$MAPBENDER_VERSION/mapbender-starter-v$MAPBENDER_VERSION.tar.gz

ENV APACHE_DOCUMENT_ROOT /srv/www/mapbender/web/

RUN set -x \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    curl \
    zlib1g-dev \
    libzip-dev \
    libbz2-dev \
    libxml2-dev \
    postgresql-server-dev-all \
    libwebp-dev \
    libjpeg-dev \
    libpng-dev \
    libxmp-dev \
    libicu-dev \
    libsqlite3-dev \
    libonig-dev \
  && rm -rf /var/lib/apt/lists/* \
  && curl -L -o /usr/bin/composer https://getcomposer.org/composer.phar \
  && chmod a+x /usr/bin/composer \
  && mkdir -p /srv/www/mapbender \
  && curl -L $MAPBENDER_URL | tar  --strip-components=1 -C /srv/www/mapbender -xz \
  && chown -R www-data:www-data /srv/www/mapbender \
  && rm /etc/apache2/sites-enabled/* \
  && docker-php-source extract \
  && docker-php-ext-install zip \
  && docker-php-ext-install bz2 \
  && docker-php-ext-install xml \
  && docker-php-ext-install json \
  && docker-php-ext-install mbstring \
  && docker-php-ext-install pdo_pgsql \
  && docker-php-ext-install gd \
  && docker-php-ext-install intl \
  && docker-php-ext-install pdo_sqlite \
  && docker-php-source delete \
  && a2enmod rewrite

COPY ./mapbender-apache.conf /etc/apache2/sites-enabled/mapbender.conf
COPY ./mapbender-console.sh /usr/local/bin/mapbender-console
COPY ./mapbender-composer.sh /usr/local/bin/mapbender-composer

USER www-data
VOLUME /srv/www/mapbender/
WORKDIR /srv/www/mapbender/

USER root

RUN set -x \
  && mapbender-console assets:install
