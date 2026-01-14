module Morphosource
  # Mix-in Morphosource MimeTypes module to Hyrax FileSetBehavor
  module FileSetBehavior
    extend ActiveSupport::Concern
    include Hyrax::FileSetBehavior
    include Morphosource::FileSetCharacterization
    include Morphosource::Works::MimeTypes
    include Morphosource::FileSetDerivatives
    include Morphosource::AccessControls::FileSetPermissions
  end
end
