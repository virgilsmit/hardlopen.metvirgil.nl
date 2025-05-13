#!/bin/bash

# Startup script for Rails application
echo "Starting Rails application..."

# Kill any existing Rails server
if [ -f tmp/pids/server.pid ]; then
  echo "Stopping existing Rails server..."
  kill -9 $(cat tmp/pids/server.pid) || true
  rm -f tmp/pids/server.pid
fi

# Set environment variables
export RAILS_ENV=production
export DB_USERNAME=vsm
export DB_PASSWORD=Ludwig2406
export DB_HOST=localhost
export DB_NAME_PRODUCTION=hardlopen_metvirgil

# Start the Rails server
echo "Starting new Rails server..."
bin/rails server -p 3001 -b 'hardlopen.metvirgil.nl'
