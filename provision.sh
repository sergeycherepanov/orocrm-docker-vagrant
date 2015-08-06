#!/bin/bash

#############################################################
DIR=$(dirname $(readlink -f $0))
MYSQL_ROOT_PASSWORD=`date +%s | sha256sum | base64 | head -c 32`
SYSTEMUSER=vagrant

export DEBIAN_FRONTEND=noninteractive
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8


sudo apt-get -y update

# Install php5
sudo apt-get install -y unzip python-software-properties mc php5-dev php5-cli php5-mysql php5-curl php5-gd php5-mcrypt
sudo apt-get install -y php5-xmlrpc php5-xsl php5-common php5-intl php-pear php5-fpm
sudo php5enmod mcrypt

# Setup php5 cli options
sudo sed -i -e "s/;date.timezone\s=/date.timezone = UTC/g" /etc/php5/cli/php.ini
sudo sed -i -e "s/short_open_tag\s=\s*.*/short_open_tag = Off/g" /etc/php5/cli/php.ini
sudo sed -i -e "s/memory_limit\s=\s.*/memory_limit = 512M/g" /etc/php5/cli/php.ini
sudo sed -i -e "s/max_execution_time\s=\s.*/max_execution_time = 0/g" /etc/php5/cli/php.ini

# Setup php5 fpm options
sudo sed -i -e "s/;date.timezone\s=/date.timezone = UTC/g" /etc/php5/fpm/php.ini
sudo sed -i -e "s/short_open_tag\s=\s*.*/short_open_tag = Off/g" /etc/php5/fpm/php.ini
sudo sed -i -e "s/memory_limit\s=\s.*/memory_limit = 512M/g" /etc/php5/fpm/php.ini
sudo sed -i -e "s/max_execution_time\s=\s.*/max_execution_time = 0/g" /etc/php5/fpm/php.ini

sudo service php5-fpm restart

# Install composer
curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer.phar
sudo ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

# Add nginx repo
add-apt-repository -y ppa:nginx/stable
apt-get -q update
apt-get -y install nginx

rm -rf /var/www
ln -s /vagrant/mgmt/web /var/www

echo "server {
        listen 80 default_server;
        server_name mgmt.loc;
        root /var/www;
        index app.php;
        access_log /var/log/nginx/\$host.access_log;
        error_log /var/log/nginx/error_log info;
        try_files \$uri \$uri/ @rewrite;
        location @rewrite {
            rewrite ^/(.*)\$ /app.php/\$1;
        }
        location ~ [^/]\.php(/|\$) {
            fastcgi_split_path_info ^(.+?\.php)(/.*)\$;
            if ( !-f \$document_root\$fastcgi_script_name) {
                return 404;
            }
            fastcgi_index app.php;
            fastcgi_read_timeout 10m;
            fastcgi_pass unix:/var/run/php5-fpm.sock;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            include fastcgi_params;
        }
}" > /etc/nginx/sites-enabled/default

sudo service nginx reload

# Install MySQL
echo "mysql-server mysql-server/root_password password ${MYSQL_ROOT_PASSWORD}" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password ${MYSQL_ROOT_PASSWORD}" | sudo debconf-set-selections
echo "mysql-server mysql-server/remove_test_db false" | sudo debconf-set-selections

sudo apt-get -qqy install mysql-server

if [ "${SUDO_USER}" == "vagrant" ]; then
  mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "SET PASSWORD = PASSWORD('');"
else
  echo "[client]
user=root
password=${MYSQL_ROOT_PASSWORD}" > ${USERHOME}/.my.cnf
fi

# Install node.js
curl -sL https://deb.nodesource.com/setup | sudo bash -
sudo apt-get install -qqy nodejs

# Enable memory and swap accounting
sed -i -e \
  's/^GRUB_CMDLINE_LINUX=.+/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/' \
  /etc/default/grub
sudo update-grub

# Enable ip forwarding
sudo sed -i -e \
  's/^DEFAULT_FORWARD_POLICY=.+/DEFAULT_FORWARD_POLICY="ACCEPT"/' \
  /etc/default/ufw

sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf

# Clean up
for SERVICE in "chef-client" "puppet"; do
    sudo /usr/sbin/update-rc.d -f $SERVICE remove
    sudo rm /etc/init.d/$SERVICE
    sudo pkill -9 -f $SERVICE
done
sudo apt-get autoremove -qqy chef puppet
sudo apt-get -qq clean
sudo rm -f \
  /home/${SYSTEMUSER}/*.sh       \
  /home/${SYSTEMUSER}/.vbox_*    \
  /home/${SYSTEMUSER}/.veewee_*  \
  /var/log/messages   \
  /var/log/lastlog    \
  /var/log/auth.log   \
  /var/log/syslog     \
  /var/log/daemon.log \
  /var/log/docker.log
sudo rm -rf  \
  /var/log/chef       \
  /var/chef           \
  /var/lib/puppet

# Add docker group
sudo groupadd docker
sudo gpasswd -a ${SYSTEMUSER} docker

rm -f /home/${SYSTEMUSER}/.bash_history  /var/mail/${SYSTEMUSER}

echo "localhost" | sudo tee /etc/hostname

cat <<EOF  >> /home/${SYSTEMUSER}/.bashrc
export PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
export LC_CTYPE=C.UTF-8
lsb_release -a
EOF

readonly COMPOSE_VERSION=1.2.0

# Install Docker
#curl -sL https://get.docker.io/ | sudo sh
wget -qO- https://get.docker.com/ | sed -e "s/did_apt_get_update=/did_apt_get_update=1/g" | sudo sh

# Install Docker Compose (was: Fig)
# @see http://docs.docker.com/compose/install/
curl -o docker-compose -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m`
chmod a+x docker-compose
sudo mv docker-compose /usr/local/bin

# Install Docker-Host-Tools
# @see https://github.com/William-Yeh/docker-host-tools
DOCKER_HOST_TOOLS=( docker-rm-stopped  docker-rmi-repo  docker-inspect-attr )
for item in "${DOCKER_HOST_TOOLS[@]}"; do
  sudo curl -o /usr/local/bin/${item}  -sSL https://raw.githubusercontent.com/William-Yeh/docker-host-tools/master/${item}
  sudo chmod a+x /usr/local/bin/${item}
done
