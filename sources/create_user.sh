#CREATE USER
source /etc/easynginx/variables/port.sh
port=$(($port + 1))
echo -n "Enter user you want to create: "
read user

if [ -d "/home/$user" ] || [ $user == 'nginx' ] || [ $user == 'apache' ] || [ $user == 'root' ] || [ $user == 'www' ]; then
	echo "User already exists! Please try again!"
	exit;
else
	chmod 701 /home/
	adduser $user
	echo -n "Enter password for user $user: "
	read -s password
	echo $password | passwd --stdin $user
	mkdir /home/$user
	chown -R $user:$user /home/$user

	mkdir /home/$user/_logs
	touch /home/$user/_log/nginx_access.log
	touch /home/$user/_log/nginx_error.log
	touch /home/$user/_log/php_error.log

	chown -R root:root /home/$user/_log

	mkdir /home/$user/_sessions
	chown -R $user:$user /home/$user/_sessions

	mkdir /etc/nginx/users/$user
	mkdir /etc/php-fpm.d/users/$user

	chmod 701 /home/$user/

	#CREATE POOL FOR USER
	cp /etc/easynginx/sources/pool.conf /etc/php-fpm.d/users/$users/pool_$users.conf
	$SED -i "s/@@USER@@/$user/g" /etc/php-fpm.d/users/$users/pool_$users.conf
	$SED -i "s/@@PORT@@/$port/g" /etc/php-fpm.d/users/$users/pool_$users.conf

	rm /etc/easynginx/variables/port.sh
	touch /etc/easynginx/variables/port.sh
	echo "port=$port" >> /etc/easynginx/variables/port.sh
	touch /etc/easynginx/variables/port_$user.sh
	echo "port=$port" >> /etc/easynginx/variables/port_$user.sh

	touch /etc/easynginx/user.log
	echo "-User $user was created" >> /etc/easynginx/user.log

	echo "OK! User $user was added."
fi