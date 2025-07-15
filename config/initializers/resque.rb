require 'resque/failure/redis'
require Rails.root.join('app/models/morphosource/access_controls/permission.rb')
require Rails.root.join('app/models/morphosource/access_controls/permissions.rb')

config_file = Rails.root.join('config', 'resque.yml')
resque_config = YAML::load(ERB.new(IO.read(config_file)).result)
Resque.redis = resque_config[Rails.env]

# Monkey patch to support ActiveJob enqueue hooks on requeue
Resque::Failure::Redis.class_eval do
  def self.requeue(id, queue = nil)
    check_queue(queue)
    item = all(id)
    item['retried_at'] = Time.now.strftime("%Y/%m/%d %H:%M:%S")
    data_store.update_item_in_failed_queue(id,Resque.encode(item))
    ApplicationJob.deserialize(*item['payload']['args']).enqueue
  end
end
