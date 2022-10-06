module Morphosource
  module AccessControls
    module Permissions
      extend ActiveSupport::Concern
      include Hydra::AccessControls::Permissions
      include Hydra::AccessControls::Visibility
      include Morphosource::AccessControls::Permission
      include Morphosource::AccessControls::DownloadPermissions

      # Morphosource::AccessControls::Permission prepend is not always caught by Resque jobs in Docker
      included do 
        Hydra::AccessControls::Permission.prepend Morphosource::AccessControls::Permission
      end
    end
  end
end
