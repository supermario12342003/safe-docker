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

ENV APACHE_DOCUMENT_ROOT /root/app/web
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

EXPOSE 80

WORKDIR /root/app

RUN yes | pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=on" >> /usr/local/etc/php/conf.d/xdebug.ini

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs

RUN touch $HOME/.bashrc \
		&& printf "parse_git_branch() {\ngit branch 2> /dev/null \| sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'\n}\n"  >> $HOME/.bashrc \
		&& echo "export PS1=\"\u@\h \[\e[32m\]\w \[\e[91m\]\$(parse_git_branch)\[\e[00m\]$ \"" >> $HOME/.bashrc

ARG GITHUB_EMAIL
ARG GITHUB_NAME

RUN printf "[user]\n\temail = ${GITHUB_EMAIL}\n\tname = ${GITHUB_NAME}\n" > $HOME/.gitconfig