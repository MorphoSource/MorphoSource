require 'noid-rails'

Noid::Rails.configure do |config|
  config.namespace = 'morphosource'
end

Rails.application.configure do
  config.noid_sequence_start = 100000
end
# MorphoSourceSf::Application.config.x.noid_sequence_start = 100000
