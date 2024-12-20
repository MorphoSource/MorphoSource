require 'resque/failure/redis'

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