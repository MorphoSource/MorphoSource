require 'capybara/rspec'
require 'selenium/webdriver'
require 'axe/rspec'

# Selenium::WebDriver::Firefox::Binary.path = "/opt/firefox/firefox" || Selenium::WebDriver::Firefox::Binary.path

Capybara.register_driver :firefox_headless do |app|
  options = ::Selenium::WebDriver::Firefox::Options.new
  options.args << '--headless'

  Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)
end

Capybara.javascript_driver = :firefox_headless

RSpec.configure do |config|

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

end

RSpec::Mocks.configuration.allow_message_expectations_on_nil = true
