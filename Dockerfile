# Gunakan image PHP 8.1 dengan FPM
FROM php:8.1-fpm

# Install dependencies dan Nginx
RUN apt-get update && apt-get install -y \
    nginx \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    unzip \
    nano \
    iputils-ping \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && docker-php-ext-install pdo_mysql zip \
    && apt-get install -y default-mysql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Konfigurasi PHP-FPM
RUN docker-php-ext-install opcache

# Set working directory
WORKDIR /var/www/html

# Copy project ke container
COPY . .

# Copy konfigurasi Nginx
COPY ./docker-config/nginx/default.conf /etc/nginx/conf.d/default.conf

# Copy script entrypoint
COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh


# Set permissions for Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && \
    chmod -R 0777 /var/www/html/storage /var/www/html/bootstrap/cache

# Menjalankan Composer install
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Expose port Nginx
EXPOSE 80

# Gunakan entrypoint script
ENTRYPOINT ["docker-entrypoint.sh"]
