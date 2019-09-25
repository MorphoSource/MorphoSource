# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

require 'solr_wrapper/rake_task' unless Rails.env.production?

require 'rspec/core/rake_task'

namespace :ci do
  RSpec::Core::RakeTask.new(:spec, :tag) do |t, task_args|
    t.rspec_opts = "--tag #{task_args[:tag]}"
  end

  desc "RSpec tests for CI wrapped in with_server"
  task :wrapped_spec, [:tag] do |t, args|
    Rails.env = 'test'
    with_server 'test' do
      Rake::Task['ci:spec'].invoke(args[:tag])
    end
  end
end
