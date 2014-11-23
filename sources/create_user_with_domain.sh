#PRE_CONFIG
NGINX_SITE_CONF='/etc/nginx/domains'
PHP_POOL_DIR='/etc/php-fpm.d'
SOURCES_DIR='/etc/easynginx/sources'
SED=`which sed`

echo -n "Please enter new domain: "
read DOMAIN


# Create a new user!
echo "Please specify the username for this site?"
read USERNAME
HOME_DIR=$USERNAME
adduser $USERNAME
echo "Please enter a password for the user: $USERNAME"
read -s PASS
echo $PASS | passwd --stdin $USERNAME

# Now we need to copy the virtual host template
CONFIG=$NGINX_SITE_CONF/$DOMAIN.conf
cp $SOURCES_DIR/nginx.vhost.conf $CONFIG
$SED -i "s/@@HOSTNAME@@/$DOMAIN/g" $CONFIG
$SED -i "s#@@PATH@@#\/home\/nginx\/"$USERNAME/public_html"#g" $CONFIG
$SED -i "s/@@LOG_PATH@@/\/home\/nginx\/$USERNAME\/_logs/g" $CONFIG
$SED -i "s#@@SOCKET@@#/var/run/php-fpm/"$USERNAME"_fpm.sock#g" $CONFIG
echo "How many FPM servers would you like by default:"
read FPM_SERVERS
echo "Min number of FPM servers would you like:"
read MIN_SERVERS
echo "Max number of FPM servers would you like:"
read MAX_SERVERS
# Now we need to create a new php fpm pool config
FPMCONF="$PHP_POOL_DIR/$DOMAIN.pool.conf"

cp $SOURCES_DIR/pool.conf $FPMCONF

$SED -i "s/@@USER@@/$USERNAME/g" $FPMCONF
$SED -i "s/@@HOME_DIR@@/\/home\/nginx\/$USERNAME/g" $FPMCONF
$SED -i "s/@@START_SERVERS@@/$FPM_SERVERS/g" $FPMCONF
$SED -i "s/@@MIN_SERVERS@@/$MIN_SERVERS/g" $FPMCONF
$SED -i "s/@@MAX_SERVERS@@/$MAX_SERVERS/g" $FPMCONF
MAX_CHILDS=$((MAX_SERVERS+START_SERVERS))
$SED -i "s/@@MAX_CHILDS@@/$MAX_CHILDS/g" $FPMCONF

#ADD NGINX TO GROUP, SO IT CAN PASS ROUTES
# usermod -aG $USERNAME nginx
chmod g+rx /home/nginx/$HOME_DIR
chmod 600 $CONFIG

#CREATE TEST PHPINFO FILE
touch /home/nginx/$HOME_DIR/public_html/index.php
cat > "/home/$HOME_DIR/public_html/index.php" <<END
<?php phpinfo(); ?>
END

# set file perms and create required dirs!
mkdir -p /home/nginx/$HOME_DIR/public_html
mkdir /home/nginx/$HOME_DIR/_logs
mkdir /home/nginx/$HOME_DIR/_sessions
chmod 750 /home/nginx/$HOME_DIR -R
chmod 700 /home/nginx/$HOME_DIR/_sessions
chmod 770 /home/nginx/$HOME_DIR/_logs
chmod 750 /home/nginx/$HOME_DIR/public_html
chown -R $USERNAME:$USERNAME /home/nginx/$HOME_DIR/
chown -R nginx:nginx /home/nginx
