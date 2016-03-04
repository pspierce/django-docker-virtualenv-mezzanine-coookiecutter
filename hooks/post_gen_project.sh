#!/bin/sh

#cd {{cookiecutter.repo_name}}
docker-compose run --rm web virtualenv /virtualenv/{{cookiecutter.repo_name}}
cp web/activate.sh ./virtualenv/{{cookiecutter.repo_name}}/bin/
cp ./web/requirements.txt ./virtualenv/{{cookiecutter.repo_name}}/
docker-compose run --rm web activate.sh pip install -r  /virtualenv/{{cookiecutter.repo_name}}/requirements.txt
