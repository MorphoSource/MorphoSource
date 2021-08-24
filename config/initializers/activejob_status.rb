# config/initializers/activejob_status.rb

if Rails.cache.is_a?(ActiveSupport::Cache::NullStore)
  # Use an alternative cache store:
  # ActiveJob::Status.store = :file_store
  # ActiveJob::Status.store = :mem_cache_store
  # ActiveJob::Status.store = :redis_cache_store
  ActiveJob::Status.store = ActiveSupport::Cache::FileStore.new('tmp/cache')
    
  # Avoid using cache store that are not shared by processes (ex: memory_store).

  # The `store=` method doesn't handle multiple arguments like Rails.
  # If you need to pass argument, you should instantiate the store:
  # ActiveJob::Status.store = ActiveSupport::Cache::FileStore.new('tmp/cache')
  # ActiveJob::Status.store = ActiveSupport::Cache::RedisCacheStore.new(url: ENV['REDIS_CACHE_URL'])
end

# Setting longer status expiration than default (1 hour)
ActiveJob::Status.options = { expires_in: 30.days.to_i }