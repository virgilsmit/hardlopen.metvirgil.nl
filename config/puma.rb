max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }.to_i
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }.to_i
threads min_threads_count, max_threads_count

port 3001 # Explicitly set port to 3001

environment ENV.fetch("RAILS_ENV") { "production" }

workers ENV.fetch("WEB_CONCURRENCY") { 2 }
preload_app!

stdout_redirect '/home/vsm/webapps/hardlopen.metvirgil.nl/log/puma.stdout.log', '/home/vsm/webapps/hardlopen.metvirgil.nl/log/puma.stderr.log', true

plugin :tmp_restart
