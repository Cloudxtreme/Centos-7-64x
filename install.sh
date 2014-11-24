#!/bin/bash
#MOVE TO ETC/EASYNGINX
mkdir /etc/easynginx/
mv /tmp/Centos-7-64x/* /etc/easynginx/
cd /etc/easynginx/

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

#IPTABLE
systemctl start  iptables.service
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
service iptables save

#INSTALL NGINX
rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-2.noarch.rpm
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm

yum --enablerepo=remi,remi-php56 install -y nginx php-fpm php-common
systemctl enable nginx.service

mkdir /etc/nginx/users
mv /etc/easynginx/sources/staticfiles.conf /etc/nginx/conf.d/
mv /etc/easynginx/sources/block.conf /etc/nginx/conf.d/
mv /etc/easynginx/sources/default_ip.conf /etc/nginx/default.d/
rm -rf /etc/nginx/nginx.conf
mv /etc/easynginx/sources/nginx.conf /etc/nginx/
sed -i "s/number_cores/$number_cores/g" /etc/nginx/nginx.conf

#INSTALL PHP-FPM
yum --enablerepo=remi,remi-php56 install -y php-opcache php-pecl-apcu php-cli php-pear php-pdo php-mysqlnd php-pgsql php-pecl-mongo php-pecl-sqlite php-pecl-memcache php-pecl-memcached php-gd php-mbstring php-mcrypt php-xml
rm -rf /etc/php-fpm.d/www.conf
rm -rf /etc/php-fpm.conf
mv /etc/easynginx/sources/php-fpm.conf /etc/
rm -rf /etc/php.ini
mv /etc/easynginx/sources/php.ini /etc/

systemctl enable php-fpm.service

#INSTALL MARIADB
yum -y update
yum -y install mariadb-server mariadb-client
systemctl start mariadb
mysql_secure_installation
cp -fr /etc/easynginx/sources/my.cnf /etc/
systemctl enable MariaDB.service

#MOVE MENU, SOURCE
mv /etc/easynginx/sources/easynginx /bin/
chmod +x /bin/easynginx
chmod 600 /etc/easynginx/sources/*.sh
chmod 700 -R /etc/easynginx/

#RESTART VPS!!!!!!!!!!!!!
#/sbin/shutdown -r now