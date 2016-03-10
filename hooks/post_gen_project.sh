#!/bin/sh

set -x

wait_on_postgres() {
    x=1
    counter=0
    while [ $x -gt 0 ]
    do
        sleep 10
        if [[ "$(docker logs {{cookiecutter.repo_name}}_postgres_1| grep '$1')" ]];
        then
            return 0
        fi

        x=$?
        counter=$(( $counter + 1 ))
        if [[ $counter -gt 8 ]];
        then
            echo "It just didn't work out."
            return 1
        fi
    done
}

cwd=$(pwd)
sudo rm $cwd/postgresql/data/.test
docker-compose up -d postgres

wait_on_postgres
if [[ "$(wait_on_postgres 'CREATE ROLE')" == 1 ]];
then
    docker-compose stop postgres;
    exit 1;
fi

docker-compose stop postgres
docker-compose up -d postgres

wait_on_postgres
if [[ "$(wait_on_postgres 'database system is ready to accept connections')" == 1 ]];
then
    docker-compose stop postgres;
    exit 1;
fi

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
