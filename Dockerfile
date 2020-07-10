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

ARG USER
RUN useradd -ms /bin/bash $USER
ENV APACHE_DOCUMENT_ROOT /home/$USER/app/web
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
WORKDIR /home/$USER/app
RUN mkdir /home/$USER/app/web && echo "Hello Safe<?php phpinfo();" > /home/$USER/app/web/index.php && chmod -R 755 /home/$USER/app/web && chown -R $USER /home/$USER/app

RUN touch home/$USER/.bashrc \
		&& printf "parse_git_branch() {\ngit branch 2> /dev/null \| sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'\n}\n"  >> /home/$USER/.bashrc \
		&& echo "export PS1=\"\u@\h \[\e[32m\]\w \[\e[91m\]\$(parse_git_branch)\[\e[00m\]$ \"" >> /home/$USER/.bashrc

RUN printf "[user]\n\temail = ${EMAIL}\n\tname = $USER\n" > /home/$USER/.gitconfig
