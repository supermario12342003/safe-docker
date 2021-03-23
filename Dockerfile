FROM php:7.2-apache
EXPOSE 80

#install composer
RUN cd /tmp && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer
#install git
RUN apt-get update -y
RUN apt-get install -y git

#install node
RUN apt -y install curl dirmngr apt-transport-https lsb-release ca-certificates && curl -sL https://deb.nodesource.com/setup_12.x | bash - && apt-get install -y nodejs > /dev/null

RUN useradd -rm -s /bin/bash -g www-data -u 1000 dev
WORKDIR /home/dev

#setup bash
RUN printf "parse_git_branch() {\ngit branch 2> /dev/null \| sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'\n}\n"  > .bashrc \
		&& echo "export PS1=\"\u@\h \[\e[32m\]\w \[\e[91m\]\$(parse_git_branch)\[\e[00m\]$ \"" >> .bashrc

ENV APACHE_DOCUMENT_ROOT /home/dev/wordpress/web
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

#install mysql
RUN docker-php-ext-install mysqli pdo pdo_mysql

#install zip
RUN apt-get install -y \
    zlib1g-dev \
    libzip-dev
RUN docker-php-ext-install zip

#install xdebug
RUN yes | pecl -q install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    #&& echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    #&& echo "xdebug.remote_autostart=on" >> /usr/local/etc/php/conf.d/xdebug.ini
    #https://stackoverflow.com/questions/64776338/xdebug-3-the-setting-xdebug-remote-has-been-renamed-see-the-upgrading-g
    && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/xdebug.ini

RUN apt-get install -y unzip
RUN apt-get install -y vim
RUN pecl install imagick-3.4.3 && docker-php-ext-enable imagick