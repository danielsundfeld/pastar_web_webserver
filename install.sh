#!/bin/bash
INSTALL_DIR="/opt/pastar_web_webserver"
AWS_KEY_FILE="$INSTALL_DIR/.aws_keys"

sudo apt update
sudo apt install -y build-essential python3-django python3-pip python3-venv libcurl4-openssl-dev libssl-dev python-celery-common nginx

sudo cp -apv webserver $INSTALL_DIR
cd $INSTALL_DIR
python3 -m venv venv
source venv/bin/activate
python3 -m pip install -r requirements.txt
deactivate
#TODO fixup
python3 -m pip install -r requirements.txt
cd -

echo "Please enter the AWS_ACCESS_KEY"
read AWS_ACCESS_KEY_ID
echo "Please enter the AWS_SECRET_ACCESS_KEY"
read AWS_SECRET_ACCESS_KEY

AWS_REGION=$(curl http://169.254.169.254/latest/meta-data/placement/region 2>/dev/null)
echo "Installing for $AWS_REGION region"

cat > $AWS_KEY_FILE <<EOL
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
AWS_REGION=$AWS_REGION
EOL

chmod 400 $AWS_KEY_FILE

cd ./deploy
sudo pip install uwsgi
sudo rm /etc/nginx/sites-enabled/default
sudo cp pastar_web_nginx.conf /etc/nginx/sites-available/
sudo ln -s ../sites-available/pastar_web_nginx.conf /etc/nginx/sites-enabled/
sudo systemctl stop nginx
sudo systemctl start nginx

sudo mkdir -p /etc/uwsgi/vassals
sudo cp pastar_web_uwsgi.ini /etc/uwsgi/vassals/
sudo touch /var/log/uwsgi-emperor.log
sudo chown ubuntu:ubuntu /var/log/uwsgi-emperor.log

sudo cp pastar_web.service /etc/systemd/system/
sudo systemctl enable pastar_web
sudo systemctl start pastar_web

sudo mkdir /var/log/celery/
sudo chown ubuntu:ubuntu /var/log/celery/
sudo cp pastar_web_celery.service /etc/systemd/system/
sudo systemctl enable pastar_web_celery
sudo systemctl start pastar_web_celery
