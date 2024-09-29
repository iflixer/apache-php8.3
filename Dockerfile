FROM php:8.3-apache

RUN cd /tmp \
	&& curl -o ioncube.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && tar -xvvzf ioncube.tar.gz \
    && mv ioncube/ioncube_loader_lin_8.3.so /usr/local/lib/php/extensions/* \
    && rm -Rf ioncube.tar.gz ioncube \
    && echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20230831/ioncube_loader_lin_8.3.so" > /usr/local/etc/php/conf.d/00_docker-php-ext-ioncube_loader_lin_8.3.ini

RUN echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20230831/opcache.so" > /usr/local/etc/php/conf.d/01-opcache.ini


RUN docker-php-ext-install pdo_mysql mysqli

RUN apt-get update && apt-get install -y \
		libfreetype-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
		libwebp-dev \
		libavif-dev \
        zip libzip-dev

RUN docker-php-ext-install zip
RUN docker-php-ext-install exif
RUN a2enmod rewrite

RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-install -j$(nproc) gd

RUN pecl install redis && docker-php-ext-enable redis

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY ./90-php-flix.ini "$PHP_INI_DIR/conf.d/"
