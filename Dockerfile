# Stage 1: Build dependency optimization
FROM composer:2.6 as vendor

WORKDIR /app
COPY database/ database/
COPY composer.json composer.json
COPY composer.lock composer.lock

RUN composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --no-dev \
    --prefer-dist

# Stage 2: Production runtime environment
FROM php:8.2-fpm-alpine

WORKDIR /var/www/html

# Install production core extensions
RUN apk add --no-cache unzip nginx supervisor libpng-dev libjpeg-turbo-dev freetype-dev \
    && docker-php-ext-configure gnu --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql bcmath gd

# Copy application layers
COPY . .
COPY --from=vendor /app/vendor/ vendor/

# Production environment isolation configuration
COPY ./docker/nginx.conf /etc/nginx/nginx.conf
COPY ./docker/supervisor.conf /etc/supervisor/conf.d/supervisor.conf

EXPOSE 80

CMD ["/usr/bin/supervisor", "-c", "/etc/supervisor/conf.d/supervisor.conf"]
