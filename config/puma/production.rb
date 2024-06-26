before_fork do
  PumaWorkerKiller.config do |config|
    # config.ram           = ( ENV.fetch("PUMA_WORKER_MEMORY_LIMIT") { 10240 } ).to_i # MiB, default is 10 GiB
    # config.frequency     = 300 # seconds
    # config.percent_usage = 0.99
    config.rolling_restart_frequency = ( ENV.fetch("PUMA_WORKER_RESTART_HOURS") { 12 } ).to_i.hours
  end
  # checks memory usage and kill processes as needed
  # PumaWorkerKiller.start
  
  # but checking memory usage in a container is dubious! so using rolling restarts for now
  PumaWorkerKiller.enable_rolling_restart
end

worker_timeout 3600 # 1 hour timeout, to match Apache timeout
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count
bind 'tcp://0.0.0.0:3000'
workers ENV.fetch("WEB_CONCURRENCY") { 2 }
preload_app!
activate_control_app 'tcp://0.0.0.0:9293', { no_token: true }
