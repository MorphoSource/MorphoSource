module Morphosource
  class ApplicationJobWithStatus < Hyrax::ApplicationJob
    include ActiveJob::Status

    rescue_from Exception do |e|
      status.update(status: :failed)
      status.update(exception: "#{e.class.to_s} (#{e.message})")
      raise e
    end
  end
end