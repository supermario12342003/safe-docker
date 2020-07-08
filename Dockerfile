FROM php:7.2-apache
#install composer
RUN cd /tmp && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

RUN apt-get update -y && apt-get install -y libpng-dev
#install git
RUN apt-get install -y git

#install mysql
RUN docker-php-ext-install mysqli pdo pdo_mysql

#install gd
RUN docker-php-ext-install gd
RUN docker-php-ext-install zip

#TODO npm, git and bash configure

ENV APACHE_DOCUMENT_ROOT /home/safe/app/web
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

EXPOSE 80

RUN useradd -ms /bin/bash safe
WORKDIR /home/safe/app
RUN mkdir /home/safe/app/web && echo "Hello Safe<?php phpinfo();" > /home/safe/app/web/index.php && chmod -R 755 /home/safe/app/web && chown -R safe /home/safe/app

RUN yes | pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=on" >> /usr/local/etc/php/conf.d/xdebug.ini

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs
