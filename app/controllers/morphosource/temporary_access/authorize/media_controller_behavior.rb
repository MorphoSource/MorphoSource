module Morphosource
  module TemporaryAccess
    module Authorize
      # Customize by inheriting classes for specific kinds of temporary access links
      module MediaControllerBehavior
        extend ActiveSupport::Concern
        include TemporaryAccessControllerBehavior

        def temporary_access_link_class
          TemporaryMediaAccessLink
        end

        def accessed_document_id_field
          :media_id
        end
      end
    end
  end
end
