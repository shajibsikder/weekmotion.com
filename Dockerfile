# =========================
# Stage 1: Composer build
# =========================
FROM composer:2.6 AS vendor

WORKDIR /app

# Dependency files first (better cache)
COPY composer.json composer.lock ./
COPY database/ database/

RUN composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --no-dev \
    --prefer-dist \
    --optimize-autoloader

# =========================
# Stage 2: Runtime
# =========================
FROM php:8.2-fpm-alpine

WORKDIR /var/www/html

# System dependencies (minimal production-safe set)
RUN apk add --no-cache \
    nginx \
    supervisor \
    unzip \
    zip \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev

# PHP extensions (Laravel core requirements)
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        pdo_mysql \
        bcmath \
        gd \
        zip

# Copy application (optimized layering)
COPY . .

# Copy vendor from build stage
COPY --from=vendor /app/vendor/ vendor/

# Config files
COPY ./docker/nginx.conf /etc/nginx/nginx.conf
COPY ./docker/supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# Laravel required directories + secure permissions
RUN mkdir -p storage bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Ensure correct ownership for full app
RUN chown -R www-data:www-data /var/www/html

# Expose HTTP port
EXPOSE 80

# Start supervisor (manages nginx + php-fpm + workers)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisor.conf"]
