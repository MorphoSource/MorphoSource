module Hyrax
  # Stub overwriting Hyrax::UserStatImporter to communicate this service is deprecated
  class UserStatImporter
    def initialize(options = {})
      raise "Hyrax::UserStatImporter is deprecated, use Morphosource::Analytics::MediaViewStatImporter instead"
    end
  end
end