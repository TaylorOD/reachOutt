max_threads = ENV.fetch('RAILS_MAX_THREADS', 5)
min_threads = ENV.fetch('RAILS_MIN_THREADS', max_threads)
threads min_threads, max_threads

port ENV.fetch('PORT', 3000)
environment ENV.fetch('RAILS_ENV', 'development')
pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')
plugin :tmp_restart
