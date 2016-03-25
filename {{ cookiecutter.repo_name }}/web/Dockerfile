FROM python:2.7

RUN useradd -s /bin/bash -u {{cookiecutter.uid}} -M {{cookiecutter.repo_name}}_user

COPY  ./{{cookiecutter.repo_name}}/web/activate.sh /usr/local/bin/activate.sh
RUN chmod +x /usr/local/bin/activate.sh

USER {{cookiecutter.repo_name}}_user

ENV PYTHONUNBUFFERED 1
EXPOSE 8000
CMD ["activate.sh", "gunicorn", "--log-file=-", "--workers 4", "--name {{cookiecutter.repo_name}}_gunicorn", "-b 0.0.0.0:8000", "{{cookiecutter.repo_name}}.wsgi:application"]
