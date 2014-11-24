#CREATE USER
echo -n "Enter user you want to create: "
read user

if [ -d "/home/$user" ] || [ $user == 'nginx' ] || [ $user == 'apache' ] || [ $user == 'root' ] || [ $user == 'www' ]; then
	echo "User already exists! Please try again!"
	exit;
else
	adduser $USERNAME
	echo -n "Enter password for user $user: "
	read -s password
	echo $password | passwd --stdin $user
fi

