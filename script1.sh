
sudo yum module reset php -y
sudo yum module enable php:7.4 -y 
sudo dnf install httpd php php-mysqlnd php-gd php-xml mariadb-server mariadb php-mbstring php-json -y
sudo yum install php-intl -y
sudo dnf install mariadb-server mariadb -y
sudo systemctl start mariadb
sudo mysql_secure_installation <<EOF

y
secret
secret
y
y
y
y
EOF

sudo mysql -u root --password=secret -e "CREATE USER 'wiki'@'localhost' IDENTIFIED BY 'Testing12345';"
sudo mysql -u root --password=secret -e "CREATE DATABASE wikidatabase;"  
sudo mysql -u root --password=secret -e "GRANT ALL PRIVILEGES ON wikidatabase.* TO 'wiki'@'localhost';"
sudo mysql -u root --password=secret -e "FLUSH PRIVILEGES;"
sudo systemctl enable mariadb
sudo systemctl enable httpd
cd /home
sudo wget https://releases.wikimedia.org/mediawiki/1.37/mediawiki-1.37.0.tar.gz
cd /var/www
sudo tar -zxf /home/mediawiki-1.37.0.tar.gz
sudo ln -s mediawiki-1.37.0/ mediawiki
sudo cp /tmp/wiki.conf /etc/httpd/conf/httpd.conf
sudo chown -R apache:apache /var/www/mediawiki
sudo service httpd restart
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo systemctl restart firewalld
sudo getenforce
sudo restorecon -FR /var/www/mediawiki-1.37.0/
sudo restorecon -FR /var/www/mediawiki
