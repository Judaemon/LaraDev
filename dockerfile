FROM serversideup/php:8.3-fpm-nginx

# Enable OPcache for production deployment
ENV PHP_OPCACHE_ENABLE=1 

USER root

RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs

# Ensure proper permissions for NGINX configuration
# RUN chown -R www-data:www-data /etc/nginx

# Copy Laravel app
COPY --chown=www-data:www-data ./ /var/www/html

USER www-data

RUN npm install
RUN npm run build

RUN composer install --no-interaction --optimize-autoloader --no-dev
