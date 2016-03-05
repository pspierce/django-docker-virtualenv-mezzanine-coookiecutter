#!/bin/sh

set -x

#cd {{cookiecutter.repo_name}}
echo `pwd`
rm ./postgresql/data/.test
docker-compose build web
docker-compose up -d postgres

echo "Continue [Y/n]?"
read continue

docker-compose stop postgres
docker-compose up -d postgres

sudo sed -i '/host all all 127.0.0.1\/32 trust/a host all all 172.17.0.1\/16 trust' ./postgresql/data/pg_hba.conf
docker-compose stop postgres
docker-compose run --rm postgres sh -c 'exec createdb -U postgres -h "$POSTGRES_PORT_5432_TCP_ADDR" {{cookiecutter.repo_name}}';

docker-compose run --rm web virtualenv /virtualenv/{{cookiecutter.repo_name}}
sudo cp web/activate.sh ./virtualenv/{{cookiecutter.repo_name}}/bin/
docker-compose run --rm web activate.sh pip install -r  /virtualenv/{{cookiecutter.repo_name}}/requirements/{{cookiecutter.dev_or_prod}}.txt
docker-compose run --rm web activate.sh ./manage.py migrate
docker-compose run --rm web activate.sh ./manage.py createsuperuser
docker-compose run --rm web activate.sh ./manage.py collectstatic
docker-compose run --rm web activate.sh ./manage.py startapp {{cookiecutter.repo_name}}
