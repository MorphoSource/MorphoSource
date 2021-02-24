module Morphosource
  module AccessControls
    module Permissions
      extend ActiveSupport::Concern
      include Hydra::AccessControls::Permissions
      include Hydra::AccessControls::Visibility
      include Morphosource::AccessControls::Permission
      include Morphosource::AccessControls::DownloadPermissions
    end
  end
end
