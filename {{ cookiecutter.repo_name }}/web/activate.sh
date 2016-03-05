#!/bin/bash

source /virtualenv/{{cookiecutter.repo_name}}/bin/activate
cd $VIRTUAL_ENV
exec $@
