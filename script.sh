#!/bin/bash

#-------------------------------------------------------------------------------
# LAMP PHP v5.3.10
#
# Run this script AFTER precise32 has installed. Including it from the
# Vagrantfile was problematic.
#-------------------------------------------------------------------------------

echo "------------------------------------------------------------------------"
echo "Begin lamp53 script"
echo "------------------------------------------------------------------------"

# Prepare apt-get
sudo apt-get update
sudo apt-get upgrade
# sudo shutdown -r now

# sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
# sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"

# Install Software
sudo apt-get install git vim apache2 mysql-server libapache2-mod-auth-mysql php5-mysql
sudo mysql_install_db
sudo /usr/bin/mysql_secure_installation
sudo apt-get install php5 libapache2-mod-php5 php5-mcrypt
sudo apt-get install php5-cgi php5-cli php5-curl php5-common php5-gd php5-mysql php5-xdebug

# Install phpMyAdmin
mkdir /home/vagrant/github
cd /home/vagrant/github
git clone https://github.com/paulboco/phpmyadmin-insecure.git phpmyadmin
cd /etc/apache2/sites-available
sudo cp default phpmyadmin
sudo sed -i -e 's|/var/www|/vagrant/public|g' default
sudo sed -i -e 's|AllowOverride None|AllowOverride All|g' default
sudo sed -i -e 's|/var/www|/home/vagrant/github/phpmyadmin|g' phpmyadmin
sudo sed -i -e "s|@localhost|@localhost\n\tServerName phpmyadmin.53|g" phpmyadmin
sudo a2ensite phpmyadmin

# Enable Mods
sudo a2enmod rewrite

# Edit php.ini
sudo sed -i -e 's|display_errors = Off|display_errors = On|g' /etc/php5/apache2/php.ini
sudo sed -i -e 's|html_errors = Off|html_errors = On|g' /etc/php5/apache2/php.ini
echo "\n# Zend Extensions" | sudo tee -a /etc/php5/apache2/php.ini
echo 'zend_extension="/usr/lib/php5/20090626+lfs/xdebug.so"' | sudo tee -a /etc/php5/apache2/php.ini

# Set Apache2 Default Host Name
echo "ServerName localhost" | sudo tee /etc/apache2/httpd.conf

# Restart Apache2
sudo service apache2 restart

# Clean up
echo "------------------------------------------------------------------------"
echo "Cleaning up. Please wait..."
echo "------------------------------------------------------------------------"
sudo apt-get clean
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm -f /EMPTY
cat /dev/null > ~/.bash_history && history -c

# Done
echo "------------------------------------------------------------------------"
echo "End lamp53 script"
echo "------------------------------------------------------------------------"
