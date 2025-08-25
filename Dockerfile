FROM php:8.3-apache

# ENTRYPOINT 用スクリプトをコピー
COPY ./docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# PHP拡張ビルド
RUN apt-get update && apt-get install -y --no-install-recommends \
  libicu-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libzip-dev libmagickwand-dev imagemagick \
  && docker-php-ext-configure gd --with-jpeg --with-freetype \
  && docker-php-ext-install -j$(nproc) gd intl pdo_mysql zip bcmath exif sockets \
  && pecl install apcu imagick \
  && docker-php-ext-enable apcu imagick exif \
  && apt-get purge -y --auto-remove libicu-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libzip-dev libmagickwand-dev \
  && apt-get install -y --no-install-recommends libicu76 libzip5 \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Node.js + Yarn（必要なときだけ）
RUN apt-get update && apt-get install -y curl gnupg \
  && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
  && apt-get install -y nodejs \
  && npm install -g yarn \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Apache 設定
COPY ./docker/php-apache/site.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod headers rewrite \
  && echo "ServerName qumuinc_php83" > /etc/apache2/conf-available/fqdn.conf \
  && a2enconf fqdn

# PHP 設定
COPY ./docker/php-apache/php.ini /usr/local/etc/php/conf.d/custom.ini

# tmp ディレクトリ権限は ENTRYPOINT で調整するのでここでは作るだけ
RUN mkdir -p tmp/cache/models tmp/cache/persistent

EXPOSE 80 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]