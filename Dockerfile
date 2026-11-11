# tahap 1: pasang dependensi PHP dengan Composer
FROM composer:2 AS vendor
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction \
      --prefer-dist --optimize-autoloader

# tahap 2: image akhir yang dijalankan
FROM php:8.4-apache

RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo_pgsql \
    && rm -rf /var/lib/apt/lists/*

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

RUN sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf \
    && sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8080>/' /etc/apache2/sites-available/000-default.conf \
    && sed -i '/DocumentRoot/a\    <Directory /var/www/html>\n        AllowOverride All\n        Require all granted\n        FallbackResource /index.php\n    </Directory>' /etc/apache2/sites-available/000-default.conf

EXPOSE 8080

COPY --from=vendor /app/vendor /var/www/html/vendor
COPY . /var/www/html
