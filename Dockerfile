FROM php:7.4-apache
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
  docker-php-ext-install gd intl pdo pdo_mysql zip 
RUN pecl install imagick && \
  docker-php-ext-enable imagick
COPY ./docker/php-apache/site.conf /etc/apache2/sites-available/000-default.conf

RUN echo '\
  log_errors = On\n\
  error_log = /dev/stderr\n\
  error_reporting = E_ALL\n\
  ' >> /usr/local/etc/php/php.ini

# RUN pecl install xdebug \
#   && docker-php-ext-enable xdebug

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
