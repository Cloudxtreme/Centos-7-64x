#!/bin/bash

#CLEAN BEFORE INSTALL
clear
yum clean all
yum update
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

#REPO
rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm

yum install nginx
systemctl enable nginx.service
systemctl restart nginx.service

#INSTALL MARIA DATABASE
yum install mariadb-server mariadb
systemctl start mariadb
mysql_secure_installation
cp -fr /tmp/Centos-7-64x/sources/my.cnf /etc/

systemctl enable mariadb.service
systemctl restart mariadb.service

#INSTALL PHP
yum install php php-mysql php-fpm

cp -fr /tmp/Centos-7-64x/sources/php.ini /etc/
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php.ini
cp -fr /tmp/Centos-7-64x/sources/nginx.conf /etc/nginx/
sed -i 's/number_cores/$number_cores/g' /etc/nginx/nginx.conf