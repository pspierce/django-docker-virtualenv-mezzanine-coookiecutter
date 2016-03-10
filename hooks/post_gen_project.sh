#!/bin/sh

set -x

read command
cwd=$(pwd)
sudo rm $cwd/postgresql/data/.test
docker-compose rm -v {{cookiecutter.repo_name}}_postgres_1
docker-compose up -d postgres
docker-compose stop postgres
docker-compose up -d postgres
docker-compose run --rm postgres sh -c 'exec createdb -U postgres -h 127.0.0.1 {{cookiecutter.repo_name}}';
read command

#docker-compose build web
docker-compose run --rm web virtualenv /virtualenv/{{cookiecutter.repo_name}}
sudo cp web/activate.sh ./virtualenv/{{cookiecutter.repo_name}}/bin/
docker-compose run --rm web activate.sh pip install -r  /virtualenv/{{cookiecutter.repo_name}}/requirements/{{cookiecutter.dev_or_prod}}.txt
docker-compose run --rm web activate.sh ./manage.py migrate
docker-compose run --rm web activate.sh ./manage.py createsuperuser
docker-compose run --rm web activate.sh ./manage.py collectstatic
docker-compose run --rm web activate.sh ./manage.py startapp {{cookiecutter.repo_name}}
