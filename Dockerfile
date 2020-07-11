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

EXPOSE 80

RUN yes | pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=on" >> /usr/local/etc/php/conf.d/xdebug.ini

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs

RUN apt-get install unzip

ARG gid
RUN useradd -rm -s /bin/bash -g ${gid} -u 1000 safe-dev

ENV APACHE_DOCUMENT_ROOT /home/safe-dev/www
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

WORKDIR /home/safe-dev/
RUN printf "parse_git_branch() {\ngit branch 2> /dev/null \| sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'\n}\n"  > .bashrc \
		&& echo "export PS1=\"\u@\h \[\e[32m\]\w \[\e[91m\]\$(parse_git_branch)\[\e[00m\]$ \"" >> .bashrc

RUN echo "alias artixor=\"cd /home/safe-dev/app/web/wp-content/plugins/wp-artixor\"" >> .bashrc
RUN echo "alias theme=\"cd /home/safe-dev/app/web/wp-content/themes/wp-safe-theme\"" >> .bashrc
RUN mkdir www && echo "Hello World<?php echo phpinfo()" > www/index.php