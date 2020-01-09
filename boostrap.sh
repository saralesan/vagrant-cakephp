#!/bin/bash

source /vagrant/config.sh

if [ -z "$APP_NAME" ]; then
    echo "You must setup a name for the app"
    exit 0
fi

APP_ROOT=/var/www/html/$APP_NAME

echo "Installing $APP_NAME in vagrant machine..."

echo "Updating packages..."
apt-get update
#apt-get -y upgrade
apt-get install -y apache2 mysql-server

echo "Installing CakePHP dependencies..."
apt-get install -y php php-cli php-json php-pdo php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath php-intl unzip
systemctl restart apache2

echo "Installing composer..."
if [ `command -v composer` ]; then
    echo "Composer is already installed"
else
    curl -s https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
fi

echo "Enabling rewrite module..."
a2enmod rewrite
cp /vagrant/templates/apache2.conf /etc/apache2/apache2.conf
systemctl restart apache2

echo "Getting CakePHP..."
# Install
chown -R vagrant:vagrant /var/www/html
cd /var/www/html
if [ -d "/var/www/html/$APP_NAME" ]; then
    echo "$APP_NAME directory exists cleaning it..."
    rm -rf /var/www/html/$APP_NAME
fi
sudo -u vagrant composer create-project --prefer-dist cakephp/app:^3.8 $APP_NAME

echo "Setting database..."
CONFIG_DB_TEMPLATE="/vagrant/templates/init_db.sql"
CONFIG_DB="/tmp/init_db.sql"
cp -f $CONFIG_DB_TEMPLATE $CONFIG_DB

# Generate config file
sed -i "s/DB_NAME/$DB_NAME/g" $CONFIG_DB
sed -i "s/DB_PASSWORD/$DB_PASSWORD/g" $CONFIG_DB
sed -i "s/DB_USER/$DB_USER/g" $CONFIG_DB
sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mysql/mysql.conf.d/mysqld.cnf

systemctl restart mysql

mysql -u root < $CONFIG_DB

echo "Setting up CakePHP application..."
CONFIG_APP_TEMPLATE="/vagrant/templates/app.default.php"
CONFIG_APP="/var/www/html/$APP_NAME/config/app.php"
SALT=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
sudo -u vagrant cp -f $CONFIG_APP_TEMPLATE $CONFIG_APP
sed -i "s/DB_NAME/$DB_NAME/g" $CONFIG_APP
sed -i "s/DB_PASSWORD/$DB_PASSWORD/g" $CONFIG_APP
sed -i "s/DB_USER/$DB_USER/g" $CONFIG_APP
sed -i "s/__SALT__/$SALT/g" $CONFIG_APP

HTTPDUSER=`ps aux | grep -E '[a]pache|[h]ttpd|[_]www|[w]ww-data|[n]ginx' | grep -v root | head -1 | cut -d\  -f1`
sudo chown -R vagrant:$HTTPDUSER $APP_ROOT
setfacl -R -m u:${HTTPDUSER}:rwx $APP_ROOT/tmp
setfacl -R -d -m u:${HTTPDUSER}:rwx $APP_ROOT/tmp
setfacl -R -m u:${HTTPDUSER}:rwx $APP_ROOT/logs
setfacl -R -d -m u:${HTTPDUSER}:rwx $APP_ROOT/logs
