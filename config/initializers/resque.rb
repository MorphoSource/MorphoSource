config_file = Rails.root.join('config', 'resque.yml')
resque_config = YAML::load(ERB.new(IO.read(config_file)).result)
Resque.redis = resque_config[Rails.env]