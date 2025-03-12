#!/bin/sh
set -e

# Change to the Laravel root directory
cd /var/www/html

# Ensure SQLite database exists
mkdir -p database
touch database/database.sqlite

# Run migrations
php artisan migrate --force
