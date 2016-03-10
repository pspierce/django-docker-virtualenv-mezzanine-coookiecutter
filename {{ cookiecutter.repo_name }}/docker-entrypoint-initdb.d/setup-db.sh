#!/bin/bash

echo "host all  all    0.0.0.0/0  md5" | sudo tee -a /var/lib/postgresql/data/pg_hba.conf
echo "listen_addresses='*'" | sudo tee -a /var/lib/postgresql/data/postgresql.conf
