FROM php:7.2-apache

LABEL Rufus Mbugua - https://github.com/rufusmbugua

COPY . /var/www/html/
COPY ./docker/000-default.conf /etc/apache2/sites-available/000-default.conf

# Prepare MySQL
RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections 
RUN echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections 


# Install Additional Packages
RUN apt-get update 
RUN apt-get install --no-install-recommends -y mysql-server git zip unzip
RUN docker-php-ext-install pdo pdo_mysql
RUN a2enmod rewrite
RUN service apache2 restart
RUN service mysql start

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"  \
	&&	php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
	&& 	php composer-setup.php --install-dir=/bin   --name=composer \
	&& 	php -r "unlink('composer-setup.php');" \
	&& 	mv /bin/composer.phar /usr/local/bin/composer

# Install Composer Packages
RUN composer self-update	\
	&& cd /var/www/html		\
	&& composer update		\
		--no-ansi			\
		--no-dev			\
		--no-interaction	\
		--no-progress		\
		--prefer-dist

RUN  chmod -R 777 storage
RUN cp .env.example .env	\
	&&	php artisan key:generate

RUN chmod +x ./docker/install.sh
RUN ./docker/install.sh


VOLUME /var/www/html

WORKDIR /var/www/html

EXPOSE 80/tcp
EXPOSE 80/udp
