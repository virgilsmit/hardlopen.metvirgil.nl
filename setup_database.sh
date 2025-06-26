#!/bin/bash

# Database setup script
echo "Setting up database permissions..."

# Ensure the user has the right permissions
sudo -u postgres psql -c "ALTER USER vsm WITH CREATEDB;"
sudo -u postgres psql -c "CREATE DATABASE hardlopen_metvirgil OWNER vsm;" || true
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE hardlopen_metvirgil TO vsm;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO vsm;" hardlopen_metvirgil

echo "Database permissions set up successfully!"
HTTP ERROR 400