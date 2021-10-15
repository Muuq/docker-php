FROM php:8.0-apache
RUN apt-get update && apt-get install -y \
  nano \
  libicu-dev \
  libfreetype6-dev \
  libjpeg62-turbo-dev \
  libpng-dev \
  libzip-dev \
  libmagickwand-dev \
  && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-jpeg=/usr/include/ --with-freetype=/usr/include/ && \
  docker-php-ext-install gd intl pdo pdo_mysql zip && \
  pecl install imagick && \
  docker-php-ext-enable imagick && \
  docker-php-ext-install exif && \
  docker-php-ext-enable exif && \
  docker-php-ext-install sockets && \
  docker-php-ext-install apcu && \
  docker-php-ext-enable apcu
COPY ./docker/php-apache/site.conf /etc/apache2/sites-available/000-default.conf

RUN echo '\
  log_errors = On\n\
  error_log = /dev/stderr\n\
  error_reporting = E_ALL\n\
  apc.enabled=1\n\
  apc.shm_size=32M\n\
  apc.ttl=7200\n\
  apc.enable_cli=1\n\
  apc.serializer=php\n\
  ' >> /usr/local/etc/php/php.ini

RUN mkdir -p \
  tmp/cache/models \
  tmp/cache/persistent \
  && chown -R :www-data \
  tmp \
  && chmod -R 770 \
  tmp
RUN a2enmod headers
RUN echo ServerName $HOSTNAME > /etc/apache2/conf-available/fqdn.conf && a2enconf fqdn
RUN a2enmod rewrite \
  && service apache2 restart

EXPOSE 80
EXPOSE 443
