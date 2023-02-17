# Behavior inherited by project and team temporary link view controllers
module Morphosource
  module TemporaryAccess
    module View
      module CollectionsTemporaryLinkViewControllerBehavior
        extend ActiveSupport::Concern
        include TemporaryAccessViewControllerBehavior

        def temporary_access_link_class
          TemporaryCollectionAccessLink
        end

        def accessed_document_id_field
          :collection_id
        end
      end
    end
  end
end