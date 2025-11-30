FROM php:8.2-apache

# Install MySQL client and other dependencies
RUN apt-get update && apt-get install -y \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions required by WordPress
RUN docker-php-ext-install mysqli pdo pdo_mysql && docker-php-ext-enable mysqli

# Enable Apache modules
RUN a2enmod rewrite headers

# Copy WordPress files
COPY . /var/www/html/

# Copy and set up entrypoint script
COPY railway-entrypoint.sh /railway-entrypoint.sh
RUN chmod +x /railway-entrypoint.sh
# Create symlink for Railway's expected docker-entrypoint.sh
RUN ln -s /railway-entrypoint.sh /docker-entrypoint.sh

# Set working directory
WORKDIR /var/www/html

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html

# Expose port (Railway will set this dynamically)
EXPOSE 8080

# Start script
CMD ["/bin/bash", "-c", "/railway-entrypoint.sh && apache2-foreground"]
