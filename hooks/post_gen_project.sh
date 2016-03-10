#!/bin/sh

set -x

#cd {{cookiecutter.repo_name}}
cwd=$(pwd)
sudo rm $cwd/postgresql/data/.test
docker-compose up -d postgres
docker-compose stop postgres
echo "host all  all    0.0.0.0/0  md5" | sudo tee -a $cwd/postgresql/data/pg_hba.conf
echo "listen_addresses='*'" | sudo tee -a $cwd/postgresql/data/postgresql.conf
docker-compose up -d postgres

x=1
counter=0
while [ $x -gt 0 ]
do
    sleep 10
    psql -h 127.0.0.1 -U scottpierce_user -t -c "select now()" template1 2> /dev/null
    x=$?
    counter=$(( $counter + 1 ))
    if [[ $counter -gt 5 ]];
    then
        echo "It just didn't work out."
        exit 1
    fi
done

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
