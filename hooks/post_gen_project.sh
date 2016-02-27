#!/bin/sh

cd "../{{cookiecutter.repo_name}}/"
docker-compose run --rm web virtualenv /virtualenv/{{cookiecutter.repo_name}}
