### BASE: things required for all - dev, ci, prod.
FROM serversideup/php:8.3-fpm-nginx AS base

USER root

# Install Node.js and clean up
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash && \
    apt-get install -y nodejs && \
    apt-get clean

WORKDIR /var/www/html

### BUILD: things required for dev & ci.
FROM base AS build

USER www-data

WORKDIR /var/www/html

# Copy and install npm dependencies
COPY --chown=www-data:www-data package.json package-lock.json ./
RUN npm install --production

# Copy and install Composer dependencies
COPY --chown=www-data:www-data composer.json composer.lock ./
RUN composer install --no-interaction --no-plugins --no-scripts --prefer-dist --no-dev && \
    composer dump-autoload --optimize

# Copy application code
COPY --chown=www-data:www-data ./ /var/www/html

### DEV: specific to local (if any)
FROM build AS dev

USER www-data

# Install dev dependencies (if needed)
RUN npm install && \
    composer install --no-interaction --no-plugins --no-scripts --prefer-dist

### STAGING and PROD - for deployment
FROM base AS prod

ENV AUTORUN_ENABLED="true" \
    AUTORUN_LARAVEL_MIGRATION_ISOLATION="false" \
    AUTORUN_LARAVEL_CONFIG_CACHE="true" \
    PHP_OPCACHE_ENABLE="1"

USER www-data

# Copy only production dependencies and application code from the build stage
COPY --from=build --chown=www-data:www-data /var/www/html /var/www/html

# Optimize for production
RUN php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache