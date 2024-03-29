#!/bin/bash
#CREATE DOMAIN

SED=`which sed`
cd /etc/easynginx/sources/
echo -n "Enter user you want to create domain: "
read user

if [ -d "/home/$user" ]; then
	echo -n "Enter domain you want to create for user $user: "
	read domain

	if [ -d "/home/$user/$domain" ]; then
		echo -n "Domain already exists! Please try again"
		exit;
	else
		source /etc/easynginx/variables/port_$user.sh
		cp /etc/easynginx/sources/vhost.conf /etc/nginx/users/$user/$domain.conf
		$SED -i "s/@@PORT@@/$port/g" /etc/nginx/users/$user/$domain.conf
		$SED -i "s/@@DOMAIN@@/$domain/g" /etc/nginx/users/$user/$domain.conf
		$SED -i "s/@@USER@@/$user/g" /etc/nginx/users/$user/$domain.conf

mkdir /home/$user/$domain/
touch /home/$user/$domain/index.php
cat > "/home/$user/$domain/index.php" <<END
<?php phpinfo(); ?>
END
		chmod 701 /home/$user/$domain
		chown -R $user:$user /home/$user/$domain
		echo "OK! Domain $domain was added to user $user."
	fi
else
	echo "User don't exists. Please try again"
	exit;
fi
