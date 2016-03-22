#!/bin/bash

source /virtualenv/{{cookiecutter.repo_name}}env/bin/activate
cd $VIRTUAL_ENV
exec $@
