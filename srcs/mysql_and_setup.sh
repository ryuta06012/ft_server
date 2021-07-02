#!/bin/bash

service php7.3-fpm start
service nginx start
service mysql start

if [ $AUTO_INDEX = "off" ]; then cat /etc/nginx/sites-available/local | sed -ie "s/autoindex on/autoindex off/g" /etc/nginx/sites-available/local;fi

# Config MYSQL
echo "CREATE DATABASE wpdb;" | mysql -u root --skip-password
echo "CREATE USER 'wpuser'@'localhost' identified by 'dbpassword';" | mysql -u root --skip-password
echo "GRANT ALL PRIVILEGES ON wpdb.* TO 'wpuser'@'localhost';" | mysql -u root --skip-password
echo "FLUSH PRIVILEGES;" | mysql -u root --skip-password

chmod -R 755 /var/www/html/

service mysql start
service php7.3-fpm restart
service nginx restart

tail -f /dev/null