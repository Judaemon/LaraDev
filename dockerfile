# Base Image
FROM serversideup/php:8.3-fpm-nginx AS base
USER root

# Install system dependencies and Node.js in one layer
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs unzip && \
    rm -rf /var/lib/apt/lists/*

# Copy application code with proper permissions
COPY --chown=www-data:www-data ./ /var/www/html

# Build argument for environment configuration (default is false)
ARG DEV_MODE=false

# Build Stage (common for all environments)
FROM base AS build
ARG DEV_MODE
USER www-data
WORKDIR /var/www/html

# Install Node.js dependencies and Composer dependencies based on DEV_MODE
RUN npm install && \
    if [ "$DEV_MODE" = "true" ]; then \
        composer install --no-interaction --optimize-autoloader; \
    else \
        composer install --no-interaction --optimize-autoloader --no-dev; \
    fi

# Development Image (keeps Node.js and all dev dependencies)
FROM build AS dev
USER www-data

# CI Image (adds MySQL client)
FROM build AS ci
USER root
RUN apt-get update && \
    apt-get install -y mysql-client && \
    rm -rf /var/lib/apt/lists/* && \
    chown -R www-data:www-data /var/www/html
USER www-data

# Production Image (builds production assets and removes Node.js)
FROM build AS prod
USER root
RUN apt-get update && \
    npm run build && \
    npm uninstall -g npm && \
    apt-get purge -y nodejs && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV AUTORUN_ENABLED="true" \
    AUTORUN_LARAVEL_MIGRATION_ISOLATION="false" \
    AUTORUN_LARAVEL_CONFIG_CACHE="true" \
    PHP_OPCACHE_ENABLE="1" \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS="0"
USER www-data
