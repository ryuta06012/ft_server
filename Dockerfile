FROM debian:buster

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NOWARNINGS yes

# set up
RUN set -ex ;\
	apt-get update && apt-get -y upgrade && \
	apt-get install -y --no-install-recommends nginx mariadb-server mariadb-client \
	php-cgi php-common php-fpm php-pear php-mbstring php-zip php-net-socket php-gd \
	php-xml-util php-gettext php-mysql php-bcmath \
	openssl ca-certificates wget vim

COPY ./srcs/ /tmp/

#SSL setup
RUN mkdir /etc/nginx/ssl && \
	openssl genrsa \
	-out /etc/nginx/ssl/private.key 2048 && \
	openssl req \
	-new -key /etc/nginx/ssl/private.key \
	-out /etc/nginx/ssl/server.csr -subj "/C=JP" && \
	openssl x509 \
	-days 3650 -req -signkey /etc/nginx/ssl/private.key \
	-in /etc/nginx/ssl/server.csr \
	-out /etc/nginx/ssl/server.crt

# nginx setup
RUN mv /tmp/nginx.conf /etc/nginx/sites-available/local && \
	ln -s /etc/nginx/sites-available/local /etc/nginx/sites-enabled/ && \
	rm /etc/nginx/sites-enabled/default

#worpress setup
WORKDIR /tmp
RUN wget https://wordpress.org/latest.tar.gz && \
	tar -zxvf latest.tar.gz && \
	rm -f latest.tar.gz && \
	cp -r ./wordpress /var/www/html/ && \
	mv /tmp/wp-config.php /var/www/html/wordpress/


# phpmyadmin setup
WORKDIR /tmp
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.1.1/phpMyAdmin-5.1.1-all-languages.tar.gz && \
    tar -zxvf phpMyAdmin-5.1.1-all-languages.tar.gz && \
    rm -f phpMyAdmin-5.1.1-all-languages.tar.gz ;\
    mv phpMyAdmin-5.1.1-all-languages phpmyadmin &&\
    mv phpmyadmin/ /var/www/html/ && \
    cp /tmp/config.inc.php /var/www/html/phpmyadmin/

RUN chown -R www-data:www-data /var/www/html

EXPOSE 80 443

ENTRYPOINT /tmp/mysql_and_setup.sh