# Development Dockerfile for smarti-backend
ARG APP_ENV=development
FROM php:8.2-cli-alpine

ARG APP_ENV
ENV APP_ENV=${APP_ENV} \
    COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/composer \
    COMPOSER_CACHE_DIR=/composer/cache \
    # Speed up composer
    COMPOSER_MEMORY_LIMIT=-1 \
    COMPOSER_PROCESS_TIMEOUT=300

# Install system deps and PHP extensions in one layer
RUN set -eux; \
    apk update; \
    apk add --no-cache --virtual .persistent-deps \
      bash \
      curl \
      ca-certificates \
      icu-libs \
      libzip \
      zlib \
      libpng \
      freetype \
      libjpeg-turbo \
      sqlite; \
    apk add --no-cache --virtual .build-deps \
      $PHPIZE_DEPS \
      autoconf \
      g++ \
      make \
      libtool \
      icu-dev \
      oniguruma-dev \
      libzip-dev \
      zlib-dev \
      libpng-dev \
      freetype-dev \
      libjpeg-turbo-dev \
      libxml2-dev \
      sqlite-dev; \
    docker-php-ext-configure gd --with-freetype --with-jpeg; \
    docker-php-ext-install -j"$(getconf _NPROCESSORS_ONLN)" \
      pdo \
      pdo_mysql \
      pdo_sqlite \
      mbstring \
      bcmath \
      zip \
      intl \
      pcntl \
      gd; \
    # Enable OPcache for better performance
    docker-php-ext-enable opcache; \
    # Clean up
    apk del .build-deps; \
    rm -rf /var/cache/apk/* /tmp/* /usr/share/man/*

# Configure PHP for better performance
RUN echo "opcache.enable_cli=1" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.memory_consumption=256" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.max_accelerated_files=20000" >> /usr/local/etc/php/conf.d/opcache.ini

# Copy composer from official image
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Create app directory
WORKDIR /app

# Copy composer files first for better Docker layer caching
COPY composer.json composer.lock* ./

# Pre-install dependencies in Docker build (if composer.lock exists)
# For development, include dev dependencies to avoid missing providers
RUN if [ -f composer.lock ]; then \
      composer install --no-interaction --prefer-dist --optimize-autoloader --no-scripts; \
    fi


COPY . .
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh




RUN mkdir -p database storage/logs storage/framework/cache \
    storage/framework/sessions storage/framework/views && \
    chmod -R 775 storage database && \
    chown -R www-data:www-data storage database

# Expose port
EXPOSE 8000


ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
