#!/bin/sh

set -x

#cd {{cookiecutter.repo_name}}
cwd=$(pwd)
sudo rm $cwd/postgresql/data/.test
docker-compose up -d postgres
docker-compose stop postgres
<<<<<<< HEAD
sed -e "s/[#]\?listen_addresses = .*/listen_addresses = '*'/g" -i '/var/lib/postgresql/data/postgresql.conf'
docker-compose run --rm postgres sh -c 'exec createdb -U postgres -h "$POSTGRES_PORT_5432_TCP_ADDR" {{cookiecutter.repo_name}}';
=======
echo "host all  all    0.0.0.0/0  md5" | sudo tee -a $cwd/postgresql/data/pg_hba.conf
echo "listen_addresses='*'" | sudo tee -a $cwd/postgresql/data/postgresql.conf
docker-compose up -d postgres
docker-compose run --rm postgres sh -c 'exec createdb -U postgres -h localhost {{cookiecutter.repo_name}}';
>>>>>>> 4f3b556e9c909ec849071e91a0d935ca2516a5dd

read command
#docker-compose build web
docker-compose run --rm web virtualenv /virtualenv/{{cookiecutter.repo_name}}
sudo cp web/activate.sh ./virtualenv/{{cookiecutter.repo_name}}/bin/
docker-compose run --rm web activate.sh pip install -r  /virtualenv/{{cookiecutter.repo_name}}/requirements/{{cookiecutter.dev_or_prod}}.txt
docker-compose run --rm web activate.sh ./manage.py migrate
docker-compose run --rm web activate.sh ./manage.py createsuperuser
docker-compose run --rm web activate.sh ./manage.py collectstatic
docker-compose run --rm web activate.sh ./manage.py startapp {{cookiecutter.repo_name}}
