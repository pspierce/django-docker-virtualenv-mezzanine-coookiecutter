#!/bin/sh

set -x

cwd=$(pwd)

echo $cwd

docker rm -v $(docker ps -a| grep scottpierceme_|awk '{print $1}')
docker-compose build web
sudo rm $cwd/postgresql/data/.test
docker-compose stop
docker-compose up postgres
docker-compose up -d postgres
echo ">> Waiting for postgres to start"
WAIT=0
while ! nc -z 127.0.0.1 {{cookiecutter.postgres_port}}; do
    sleep 1
    WAIT=$(($WAIT + 1))
    if [ "$WAIT" -gt 15 ]; then
        echo "Error: Timeout wating for Postgres to start"
        exit 1
    fi
done

docker-compose run --rm web virtualenv /virtualenv/{{cookiecutter.repo_name}}env

sudo cp web/activate.sh ./virtualenv/{{cookiecutter.repo_name}}env/bin/

docker-compose run --rm web init_activate.sh pip install --no-cache-dir -r /virtualenv/{{cookiecutter.repo_name}}env/requirements.txt

docker-compose run --rm web init_activate.sh mezzanine-project {{cookiecutter.repo_name}}site


sudo mv ./web/sass \
    ./web/static \
    ./web/templates \
    ./virtualenv/{{cookiecutter.repo_name}}env/{{cookiecutter.repo_name}}site/{{cookiecutter.repo_name}}site/

sudo cp ./web/mezz_local_settings.py ./virtualenv/{{cookiecutter.repo_name}}env/{{cookiecutter.repo_name}}site/{{cookiecutter.repo_name}}site/local_settings.py

docker-compose run --rm web activate.sh python manage.py migrate
docker-compose run --rm web activate.sh python manage.py createsuperuser
docker-compose run --rm web activate.sh python manage.py collectstatic
read command
docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock --name nginx-proxy jwilder/nginx-proxy
echo "host all  all    0.0.0.0/0  md5" | sudo tee -a $cwd/postgresql/data/pg_hba.conf
docker-compose stop
docker-compose up -d
