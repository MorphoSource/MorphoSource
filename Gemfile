source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 6.1'

# Use postgresql for all environments, not just production
gem 'pg'
gem 'sass-rails', '~> 6.0'
# gem 'uglifier', '>= 1.3.0'
gem 'terser'
gem 'coffee-rails', '~> 4.2'
gem 'jbuilder', '~> 2.5'
gem 'figaro'
gem 'redis'
gem 'rsolr', '>= 1.0'
gem 'jquery-rails'
gem 'devise'
gem 'doorkeeper'
gem 'doorkeeper-openid_connect'
gem 'devise-guests', '~> 0.6'
gem 'bootstrap', '~> 4.0'

# Hyrax dependencies

# temporarily forking browse-everything until https://github.com/samvera/browse-everything/pull/442 is approved
gem 'browse-everything', github: 'MorphoSource/browse-everything', ref: '676505bfed8a5a59e039e359296c53ce65bd4097'

# pull iiif_manifest fork that can handle 3D manifests
gem 'iiif_manifest', github: 'MorphoSource/iiif_manifest', tag: 'v1.4.0'

gem 'riiif', '~> 2.2'

# used for XML validation in Crossref DOI deposit
gem 'nokogiri'

gem 'hyrax', '5.0.5'

gem 'hydra-role-management', '~> 1.1.0'

gem 'resque'
gem 'resque-kubernetes', github: 'MorphoSource/resque-kubernetes', ref: 'c5955b46678b164b4df75929d7f1e48d007cc150'
gem 'resque-pool'
gem 'resque-web', require: 'resque_web', github: 'MorphoSource/resque-web', tag: 'ms-0.0.13'

# for storing and reading ActiveJob status
gem 'activejob-status'

gem 'webpacker', '~> 4.x'

gem 'puma', '~> 7.2.1'
gem 'puma_worker_killer'

gem 'minitar'
gem 'rubyzip'
gem 'zipline', '~> 1.0'
gem 'zip_tricks'
gem 'interval_response'
gem 'http'

gem 'rest-client', '~> 2.0'

gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'activerecord-session_store'

gem 'render_async'
gem 'recaptcha'
gem 'redcarpet'
gem 'roo'
gem 'zip-zip'
gem 'caxlsx'

gem 'dalli' # mem_cache_store support

gem 'okcomputer' # Hyrax health checks

# Sentry.io error tracking
gem "sentry-ruby"
gem "sentry-rails"
gem "sentry-resque"

# Scout APM
gem "scout_apm"

# Maintenance mode
gem 'turnout'

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'solr_wrapper', '~> 2.0.0'
  gem 'fcrepo_wrapper'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'rails-controller-testing'
  gem 'factory_bot_rails', '~> 4.8'
  gem 'webmock'
  gem 'geckodriver-helper'
  gem 'shoulda-callback-matchers', '~> 1.1.1'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'dotenv-rails'
end

group :test do
  # note: the newer version of axe-matchers (2.4.1) throws the error below.  For now use 2.3.0 which is working
  # Selenium::WebDriver::Error::JavascriptError:ReferenceError: __magic__ is not defined
  gem 'axe-matchers', '~> 2.3.0'
  gem 'rspec-json_expectations'
  gem 'vcr'
  gem 'timecop'
end

gem "ezid-client", "~> 1.11.0"
