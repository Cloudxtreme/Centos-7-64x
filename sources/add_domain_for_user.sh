#CONFIG
NGINX_CONFIG='/etc/nginx/conf.d'
NGINX_SITES_ENABLED='/etc/nginx/default.d'
PHP_POOL_DIR='/etc/php-fpm.d'
# --------------END 
SED=`which sed`
CURRENT_DIR=`dirname $0`

if [ -z $1 ]; then
	echo "No domain name given"
	exit 1
fi
DOMAIN=$1

#CHECK DOMAIN VALIDATE
PATTERN="^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$";
if [[ "$DOMAIN" =~ $PATTERN ]]; then
	DOMAIN=`echo $DOMAIN | tr '[A-Z]' '[a-z]'`
	echo "Creating hosting for:" $DOMAIN
else
	echo "invalid domain name"
	exit 1 
fi

# Create a new user!
echo "Please specify the username for this site?"
read USERNAME
HOME_DIR=$USERNAME
adduser $USERNAME
echo "Please enter a password for the user: $USERNAME"
read -s PASS
echo $PASS | passwd --stdin $USERNAME

echo "Would you like to change to web root directory (y/n)?"
read CHANGEROOT
if [ $CHANGEROOT == "y" ]; then
	echo "Enter the new web root dir (after the public_html/)"
	read DIR
	PUBLIC_HTML_DIR='/public_html/'$DIR
else
	PUBLIC_HTML_DIR='/public_html'
fi

# Now we need to copy the virtual host template
CONFIG=$NGINX_CONFIG/$DOMAIN.conf
cp $CURRENT_DIR/vhost.template $CONFIG
$SED -i "s/@@HOSTNAME@@/$DOMAIN/g" $CONFIG
$SED -i "s#@@PATH@@#\/home\/"$USERNAME$PUBLIC_HTML_DIR"#g" $CONFIG
$SED -i "s/@@LOG_PATH@@/\/home\/$USERNAME\/_logs/g" $CONFIG
$SED -i "s#@@SOCKET@@#/var/run/"$USERNAME"_fpm.sock#g" $CONFIG

echo "How many FPM servers would you like by default:"
read FPM_SERVERS
echo "Min number of FPM servers would you like:"
read MIN_SERVERS
echo "Max number of FPM servers would you like:"
read MAX_SERVERS
# Now we need to create a new php fpm pool config
FPMCONF="$PHP_POOL_DIR/$DOMAIN.pool.conf"

cp $CURRENT_DIR/pool.template $FPMCONF

$SED -i "s/@@USER@@/$USERNAME/g" $FPMCONF
$SED -i "s/@@HOME_DIR@@/\/home\/$USERNAME/g" $FPMCONF
$SED -i "s/@@START_SERVERS@@/$FPM_SERVERS/g" $FPMCONF
$SED -i "s/@@MIN_SERVERS@@/$MIN_SERVERS/g" $FPMCONF
$SED -i "s/@@MAX_SERVERS@@/$MAX_SERVERS/g" $FPMCONF
MAX_CHILDS=$((MAX_SERVERS+START_SERVERS))
$SED -i "s/@@MAX_CHILDS@@/$MAX_CHILDS/g" $FPMCONF

usermod -aG $USERNAME $USERNAME
chmod g+rx /home/$HOME_DIR
chmod 600 $CONFIG

ln -s $CONFIG $NGINX_SITES_ENABLED/$DOMAIN.conf

# set file perms and create required dirs!
mkdir -p /home/$HOME_DIR$PUBLIC_HTML_DIR
mkdir /home/$HOME_DIR/_logs
mkdir /home/$HOME_DIR/_sessions
chmod 750 /home/$HOME_DIR -R
chmod 700 /home/$HOME_DIR/_sessions
chmod 770 /home/$HOME_DIR/_logs
chmod 750 /home/$HOME_DIR$PUBLIC_HTML_DIR
chown $USERNAME:$USERNAME /home/$HOME_DIR/ -R
