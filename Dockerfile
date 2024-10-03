FROM ubuntu:20.04

LABEL maintainer="hello@kesaralive.com"
LABEL description="Apache / PHP development environment with Python and pytest"

# Set ARG and Environment Variables
ARG DEBIAN_FRONTEND=noninteractive

# Install required dependencies, Python, and add the PHP PPA repository
RUN apt-get update && apt-get install -y \
    lsb-release \
    ca-certificates \
    apt-transport-https \
    software-properties-common \
    locales \
    python3 \
    python3-pip && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update

# Install Apache, PHP 8.0, and extensions
RUN apt-get install -y \
    apache2 \
    php8.0 \
    libapache2-mod-php8.0 \
    php8.0-bcmath \
    php8.0-gd \
    php8.0-sqlite3 \
    php8.0-mysql \
    php8.0-curl \
    php8.0-xml \
    php8.0-mbstring \
    php8.0-zip \
    nano && \
    locale-gen fr_FR.UTF-8 en_US.UTF-8 de_DE.UTF-8 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install pytest using pip
RUN pip3 install pytest

# Configure PHP for development
RUN sed -i -e 's/^error_reporting\s*=.*/error_reporting = E_ALL/' /etc/php/8.0/apache2/php.ini && \
    sed -i -e 's/^display_errors\s*=.*/display_errors = On/' /etc/php/8.0/apache2/php.ini && \
    sed -i -e 's/^zlib.output_compression\s*=.*/zlib.output_compression = Off/' /etc/php/8.0/apache2/php.ini

# Apache configuration
RUN a2enmod rewrite && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# Set file permissions
RUN chgrp -R www-data /var/www && \
    find /var/www -type d -exec chmod 775 {} + && \
    find /var/www -type f -exec chmod 664 {} +

# Expose Apache HTTP port
EXPOSE 80

# Start Apache in foreground
CMD ["/usr/sbin/apache2ctl","-DFOREGROUND"]
