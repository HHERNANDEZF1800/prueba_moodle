FROM php:8.1-apache

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    libpq-dev \
    libldap2-dev \
    libcurl4-openssl-dev \
    zlib1g-dev \
    git \
    unzip \
    curl \
    cron \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Configurar extensiones de PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        mysqli \
        pdo \
        pdo_mysql \
        zip \
        intl \
        opcache \
        exif \
        soap

# Instalar Redis extension
RUN pecl install redis && docker-php-ext-enable redis

# Configuración de PHP para Moodle
RUN { \
        echo 'memory_limit = 512M'; \
        echo 'upload_max_filesize = 256M'; \
        echo 'post_max_size = 256M'; \
        echo 'max_execution_time = 300'; \
        echo 'max_input_vars = 5000'; \
        echo 'file_uploads = On'; \
    } > /usr/local/etc/php/conf.d/moodle.ini

# Habilitar mod_rewrite de Apache
RUN a2enmod rewrite

# Descargar Moodle
ARG MOODLE_VERSION=MOODLE_404_STABLE
RUN git clone --depth=1 --branch ${MOODLE_VERSION} https://github.com/moodle/moodle.git /var/www/html

# Crear directorio de datos de Moodle
RUN mkdir -p /var/www/moodledata && \
    chown -R www-data:www-data /var/www/html /var/www/moodledata && \
    chmod -R 755 /var/www/moodledata

# Script de inicialización
COPY init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

WORKDIR /var/www/html

EXPOSE 80

CMD ["/usr/local/bin/init.sh"]
