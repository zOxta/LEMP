#!/bin/bash

# Based on: http://github.com/kernelcurry, http://github.com/chuckreynolds

# Retrieve Ubuntu version name
VERSION=`lsb_release -c -s`

# Variables for colored output
COLOR_INFO='\e[1;34m'
COLOR_COMMENT='\e[0;33m'
COLOR_NOTICE='\e[1;37m'
COLOR_NONE='\e[0m'

# Intro
echo -e "${COLOR_INFO}"
echo "=============================="
echo "=        HHVM && HACK        ="
echo "=           LEMP             ="
echo "=============================="
echo "= This script is to be used  ="
echo "= to install HHVM and HACK   ="
echo "= using apt-get              ="
echo "=============================="
echo -e "${COLOR_NONE}"

# Basic Packages
echo -e "${COLOR_COMMENT}"
echo "=============================="
echo "= Basic Packages             ="
echo "=============================="
echo -e "${COLOR_NONE}"
sudo apt-get update
sudo apt-get install -y unzip vim git-core curl wget build-essential python-software-properties htop

# PPA && Repositories
echo -e "${COLOR_COMMENT}"
echo "=============================="
echo "= PPA && Repositories        ="
echo "=============================="
echo -e "${COLOR_NONE}"
sudo add-apt-repository -y ppa:nginx/stable
sudo add-apt-repository -y ppa:mapnik/boost
wget -O - http://dl.hhvm.com/conf/hhvm.gpg.key | sudo apt-key add -
echo deb http://dl.hhvm.com/ubuntu $VERSION main | sudo tee /etc/apt/sources.list.d/hhvm.list
sudo apt-get update

# Nginx
echo -e "${COLOR_COMMENT}"
echo "=============================="
echo "= Installing LEMP           ="
echo "=============================="
echo -e "${COLOR_NONE}"
sudo apt-get install -y nginx mysql-server php5-fpm php5-mysql phpmyadmin php5-curl php5-mcrypt

# HHVM
echo -e "${COLOR_COMMENT}"
echo "=============================="
echo "= Installing HHVM            ="
echo "=============================="
echo -e "${COLOR_NONE}"
sudo apt-get install -y hhvm
sudo /usr/share/hhvm/install_fastcgi.sh
sudo update-rc.d hhvm defaults
sudo /etc/init.d/hhvm restart
# sudo /usr/bin/update-alternatives --install /usr/bin/php php /usr/bin/hhvm 60

# Nginx Config
echo -e "${COLOR_COMMENT}"
echo "=============================="
echo "= Nginx Config For Laravel   ="
echo "=============================="
echo -e "${COLOR_NONE}"
sudo rm /etc/nginx/sites-available/laravel-webapp
cat << EOF | sudo tee -a /etc/nginx/sites-available/laravel-webapp
server {
    listen 80 default_server;

    server_name localhost;

    charset utf-8;
    
    # laravel
    root /var/www/laravel-webapp/public;
    index index.html index.htm index.php;

    location ~* \.(?:ico|css|js|gif|jpe?g|png|svg|html|xml|otf|ttf|eot|woff)$ {
        expires 30d;
        access_log off;
        add_header Cache-Control public;
    }
    
    # laravel config
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }    

    location = /favicon.ico { log_not_found off; access_log off; }
    location = /robots.txt  { log_not_found off; access_log off; }
    location ~ /\. { deny all; log_not_found off; access_log off; }

    access_log /var/log/nginx/access.log;
    error_log  /var/log/nginx/error.log error;
    error_page 404 /index.php;
    # uncomment next line to let hhvm kick-in
    # include hhvm.conf;
}
EOF
sudo mkdir -p /var/www
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/laravel-webapp /etc/nginx/sites-enabled/laravel-webapp
sudo service nginx reload

echo -e "${COLOR_INFO}"
echo "=============================="
echo "= Install composer           ="
echo "=============================="
echo -e "${COLOR_NONE}"

curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

echo -e "${COLOR_INFO}"
echo "=============================="
echo "= Creating New Laravel App   ="
echo "=============================="
echo -e "${COLOR_NONE}"
cd /var/www
composer create-project laravel/laravel laravel-webapp --prefer-dist
sudo chmod -R 777 /var/www/laravel-webapp/app/storage

echo -e "${COLOR_INFO}"
echo "=============================="
echo "= Script Complete            ="
echo "=============================="
echo -e "${COLOR_NONE}"
