sudo apt-get update
sudo apt-get install apache2 -y
sudo service apache2 start
echo "Hello world!" > /var/www/html/index.html
