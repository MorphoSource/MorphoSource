threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count
bind "tcp://0.0.0.0:9292"
workers ENV.fetch("WEB_CONCURRENCY") { 2 }
preload_app!
