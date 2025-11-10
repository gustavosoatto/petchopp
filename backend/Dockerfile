FROM php:8.2-fpm-alpine

WORKDIR /var/www

RUN apk update && apk add --no-cache \
    postgresql-dev \
    linux-headers \
    $PHPIZE_DEPS

RUN pecl install xdebug && docker-php-ext-enable xdebug
RUN docker-php-ext-install pdo pdo_pgsql bcmath

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY composer.json composer.lock ./
RUN composer install --no-interaction --no-autoloader --no-scripts

COPY . .
RUN composer dump-autoload --optimize

RUN chown -R www-data:www-data /var/www

EXPOSE 9000
CMD ["php-fpm"]