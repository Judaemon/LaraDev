FROM serversideup/php:8.3-fpm-nginx

# Enable OPcache for production deployment
ENV PHP_OPCACHE_ENABLE=1 

USER root

RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

COPY --chown=www-data:www-data . /var/www/html

COPY --chown=root:root laravel.conf /etc/nginx/conf.d/laravel.conf

RUN chmod 644 /etc/nginx/conf.d/laravel.conf && \
    ln -sf /etc/nginx/conf.d/laravel.conf /etc/nginx/conf.d/default.conf

USER www-data

# Install Node dependencies and build frontend assets
RUN npm install && npm run build

# Install PHP dependencies
RUN composer install --no-interaction --optimize-autoloader --no-dev
