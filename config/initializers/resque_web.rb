# config/initializers/resque_web.rb

if defined?(Resque) && !defined?(Resque::Version) && defined?(Resque::VERSION)
  Resque::Version = Resque::VERSION
end