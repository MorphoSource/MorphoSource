class RemoteFileVerificationJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_medium_queue_name

  def perform
		require 'rake'
		Rake.application.load_rakefile
		Rake::Task['morphosource:verify_remote_backed_media'].invoke
  end
end