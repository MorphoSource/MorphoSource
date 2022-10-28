begin
  require 'rspec/core/rake_task'

  namespace :ci do
    RSpec::Core::RakeTask.new(:spec, :tag) do |t, task_args|
      if ENV['RSPEC_FAIL_FAST']
        t.rspec_opts = "--tag #{task_args[:tag]} --fail-fast"
      else
        t.rspec_opts = "--tag #{task_args[:tag]}"
      end
    end

    desc "RSpec tests for CI wrapped in with_server"
    task :wrapped_spec, [:tag] do |t, args|
      Rails.env = 'test'
      with_server 'test' do
        Rake::Task['ci:spec'].invoke(args[:tag])
      end
    end
  end
rescue LoadError
end