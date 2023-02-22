module Morphosource
  module TemporaryAccess
    module CollectionsControllerBehavior
      extend ActiveSupport::Concern
      include TemporaryAccessControllerBehavior

      def temporary_access_link_class
        TemporaryCollectionAccessLink
      end

      def accessed_document_id_field
        :collection_id
      end
    end
  end
end