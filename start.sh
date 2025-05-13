#!/bin/bash
cd /home/vsm/webapps/hardlopen.metvirgil.nl
export RAILS_ENV=production
bundle exec puma -C config/puma.rb
