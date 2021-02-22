module Morphosource
  module AccessControls
    module FileSetPermissions
      include Morphosource::AccessControls::DownloadPermissions
      include Morphosource::AccessControls::Permission
    end
  end
end
