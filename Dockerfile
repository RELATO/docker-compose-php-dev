FROM php:7.2-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libc-client-dev \
    libzip-dev \ 
    libkrb5-dev \
    libicu-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libssl-dev \
    zlib1g-dev \
    openssl \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl


# Install extensions
RUN docker-php-ext-install mysqli iconv pdo pdo_mysql mbstring zip exif pcntl intl
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/

RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install -j$(nproc) imap

RUN docker-php-ext-install gd
# RUN docker-php-ext-install openssl

RUN docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install opcache

#RUN pecl install apcu-5.1.5 \
#    && docker-php-ext-enable apcu

RUN locale-gen en_US.UTF-8
RUN update-locale

ENV HOME /root
ENV SHELL /bin/bash

WORKDIR /var/www/html

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*


# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 relato
RUN useradd -u 1000 -ms /bin/bash -g relato relato

# Copy existing application directory contents
# COPY . /var/www/html

# Copy existing application directory permissions
COPY --chown=relato:relato . /var/www/html

# Change current user to www
USER relato

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
