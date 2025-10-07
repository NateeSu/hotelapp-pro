FROM php:8.2-apache

# ติดตั้ง extensions ที่จำเป็น
RUN docker-php-ext-install mysqli pdo pdo_mysql

# เปิดใช้ mod_rewrite
RUN a2enmod rewrite

# ตั้งค่า working directory
WORKDIR /var/www/html

# ตั้งค่า permissions
RUN chown -R www-data:www-data /var/www/html