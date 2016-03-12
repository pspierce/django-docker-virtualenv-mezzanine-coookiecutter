#!/bin/sh

set -x

read command
cwd=$(pwd)
sudo rm $cwd/postgresql/data/.test
docker-compose rm -v {{cookiecutter.repo_name}}_postgres_1
docker-compose up postgres
read command
docker-compose up -d postgres
echo ">> Waiting for postgres to start"
WAIT=0
while ! nc -z 127.0.0.1 5432; do
    sleep 1
    WAIT=$(($WAIT + 1))
    if [ "$WAIT" -gt 15 ]; then
        echo "Error: Timeout wating for Postgres to start"
        exit 1
    fi
done
read command
#docker-compose build web
docker-compose run --rm web virtualenv /virtualenv/{{cookiecutter.repo_name}}
sudo cp web/activate.sh ./virtualenv/{{cookiecutter.repo_name}}/bin/
docker-compose run --rm web activate.sh pip install -r  /virtualenv/{{cookiecutter.repo_name}}/requirements/{{cookiecutter.dev_or_prod}}.txt
docker-compose run --rm web activate.sh ./manage.py migrate
docker-compose run --rm web activate.sh ./manage.py createsuperuser
docker-compose run --rm web activate.sh ./manage.py collectstatic
docker-compose run --rm web activate.sh ./manage.py startapp {{cookiecutter.app_name}}
docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock --name nginx-proxy jwilder/nginx-proxy
echo "host all  all    0.0.0.0/0  md5" | sudo tee -a $cwd/postgresql/data/pg_hba.conf
docker-compose stop
docker-compose up -d
