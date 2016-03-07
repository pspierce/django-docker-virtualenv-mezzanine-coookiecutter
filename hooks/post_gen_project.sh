#!/bin/sh

set -x

#cd {{cookiecutter.repo_name}}
cwd=$(pwd)
rm $cwd/postgresql/data/.test
docker-compose build web
docker-compose up -d postgres
docker-compose stop postgres
sudo echo "host all  all    0.0.0.0/0  md5" >> $cwd/postgresql/data/pg_hba.conf
sudo echo "listen_addresses='*'" >> $cwd/postgresql/data/postgresql.conf
docker-compose up -d postgres
docker-compose run --rm postgres sh -c 'exec createdb -U postgres -h "$POSTGRES_PORT_5432_TCP_ADDR" {{cookiecutter.repo_name}}';

docker-compose run --rm web virtualenv /virtualenv/{{cookiecutter.repo_name}}
sudo cp web/activate.sh ./virtualenv/{{cookiecutter.repo_name}}/bin/
docker-compose run --rm web activate.sh pip install -r  /virtualenv/{{cookiecutter.repo_name}}/requirements/{{cookiecutter.dev_or_prod}}.txt
docker-compose run --rm web activate.sh ./manage.py migrate
docker-compose run --rm web activate.sh ./manage.py createsuperuser
docker-compose run --rm web activate.sh ./manage.py collectstatic
docker-compose run --rm web activate.sh ./manage.py startapp {{cookiecutter.repo_name}}
