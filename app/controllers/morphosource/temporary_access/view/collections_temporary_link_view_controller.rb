# Handles viewing of collection through temporary access link
# TODO: All of this!
module Morphosource
  module TemporaryAccess
    module View
      class CollectionsTemporaryLinkViewController < ApplicationController
        include TemporaryAccessViewControllerBehavior

        before_action :load_temporary_access_link,
          :authorize_temporary_access_link,
          :load_curation_concern,
          :authorize_curation_concern,
          :set_authorization_cookie, only: :show
    
        def temporary_access_link_class
          TemporaryCollectionAccessLink
        end

        def accessed_document_id_field
          :collection_id
        end

        def show
          flash[:notice] = I18n.t 'morphosource.media.view.temporary_access'
          redirect_to main_app.collection_path(@curation_concern)
        end
      end
    end
  end
end