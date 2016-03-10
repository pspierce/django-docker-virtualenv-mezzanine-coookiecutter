#!/bin/bash

echo "host all  all    0.0.0.0/0  md5" | tee -a /var/lib/postgresql/data/pg_hba.conf
echo "listen_addresses='*'" | tee -a /var/lib/postgresql/data/postgresql.conf
