#!/bin/bash

#CLEAN BEFORE INSTALL
clear
yum clean all

# GET INFO CPU
number_cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )

#STOP, REMOVE, REMOVE SOMETHING
systemctl stop sendmail.service
systemctl disable sendmail.service
systemctl stop xinetd.service
systemctl disable xinetd.service
systemctl stop saslauthd.service
systemctl disable saslauthd.service
systemctl stop rsyslog.service
systemctl disable rsyslog.service
systemctl stop postfix.service
systemctl disable postfix.service
systemctl stop httpd*.service
systemctl disable httpd*.service
systemctl stop php*.service
systemctl disable php*.service
systemctl stop mysql*.service
systemctl disable mysql*.service

yum -y remove mysql*
yum -y remove php*
yum -y remove httpd*
yum -y remove sendmail*
yum -y remove postfix*
yum -y remove rsyslog*

#OPEN PORT 80
systemctl start  iptables.service
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
service iptables save
systemctl restart  iptables.service

#INSTALL NGINX
rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-2.noarch.rpm
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm

yum --enablerepo=remi,remi-php56 install -y nginx php-fpm php-common

#INSTALL MARIA DATABASE
yum install -y mariadb-server mariadb
systemctl start mariadb
mysql_secure_installation
cp -fr /tmp/Centos-7-64x/sources/my.cnf /etc/

systemctl enable mariadb.service
systemctl restart mariadb.service

#INSTALL PHP
yum --enablerepo=remi,remi-php56 install -y php-opcache php-pecl-apcu php-cli php-pear php-pdo php-mysqlnd php-pgsql php-pecl-mongo php-pecl-sqlite php-pecl-memcache php-pecl-memcached php-gd php-mbstring php-mcrypt php-xml


cp -fr /tmp/Centos-7-64x/sources/php.ini /etc/
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php.ini
cp -fr /tmp/Centos-7-64x/sources/nginx.conf /etc/nginx/
sed -i "s/number_cores/$number_cores/g" /etc/nginx/nginx.conf