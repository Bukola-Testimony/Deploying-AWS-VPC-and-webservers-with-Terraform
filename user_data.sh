#!/bin/bash

sudo apt install gpgv gpgsm gnupg-l10n gnupg dirmngr

curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
    | sudo tee /etc/apt/sources.list.d/nginx.list

echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
    | sudo tee /etc/apt/preferences.d/99nginx

sudo apt update
sudo apt install nginx
sudo systemctl start nginx.service
sudo systemctl enable nginx.service

INTERFACE=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/)
SUBNETID=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/${INTERFACE}/subnet-id)
cd /usr/share/nginx/html
touch index.txt
echo '<center><h1 style='color:blue'>This instance is in the subnet with ID: SUBNETID </h1></center>' >  index.txt
sed "s/SUBNETID/$SUBNETID/" /usr/share/nginx/html/index.txt > /usr/share/nginx/html/index.html
echo "<center><h1 style='color:green'>1 am server 1: $(hostname -f)</h1></center>"  >>  /usr/share/nginx/html/index.html
echo "<center><h2 style='color:purple'>Coded by: Bukola Testimony</h2></center>"  >>  /usr/share/nginx/html/index.html