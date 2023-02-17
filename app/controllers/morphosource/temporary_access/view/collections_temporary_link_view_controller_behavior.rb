# Behavior inherited by project and team temporary link view controllers
module Morphosource
  module TemporaryAccess
    module View
      module CollectionsTemporaryLinkViewControllerBehavior  
        def temporary_access_link_class
          TemporaryCollectionAccessLink
        end

        def accessed_document_id_field
          :collection_id
        end

        def show
          flash[:notice] = I18n.t(
            'morphosource.collections.view.temporary_access', 
            collection_type: @curation_concern.human_readable_type.downcase
          )
          super
        end
      end
    end
  end
end