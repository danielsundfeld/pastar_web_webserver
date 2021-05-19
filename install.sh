#Master
sudo apt update
sudo apt install -y build-essential python3-django python3-pip python3-venv libcurl4-openssl-dev libssl-dev python-celery-common nginx
cd webserver
python3 -m venv venv
source venv/bin/activate
python3 -m pip install -r requirements.txt
deactivate
#TODO fixup
python3 -m pip install -r requirements.txt

cd ../deploy
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

echo Now fixup -AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, CELERY_BROKER_TRANSPORT_OPTIONS
