# Handles viewing of media through temporary access link
module Morphosource
  module TemporaryAccess
    module View
      class MediaTemporaryLinkViewController < Hyrax::MediaController
        include TemporaryAccessViewControllerBehavior

        before_action :load_temporary_access_link,
          :authorize_temporary_access_link,
          :load_curation_concern,
          :authorize_curation_concern,
          :set_authorization_cookie,
          :set_curation_concern, only: :showcase
        skip_authorize_resource only: [:showcase, :thumbnail]

        # Want to make use of hyrax/media views
        def self.controller_path
          "hyrax/media"
        end

        def temporary_access_link_class
          TemporaryMediaAccessLink
        end

        def accessed_document_id_field
          :media_id
        end

        def showcase
          @presenter = show_presenter.new(@curation_concern_from_search_results, current_ability, request)
          @presenter.get_showcase_data
          flash[:notice] = I18n.t 'morphosource.media.view.temporary_access'
          render '/hyrax/media/showcase', presenter: @presenter
        end

        def set_curation_concern
          if @concern_solr_doc && Media.exists?(@concern_solr_doc.id)
            @curation_concern_from_search_results = @concern_solr_doc
            @curation_concern = Media.find(@concern_solr_doc.id)
          end
        end
      end
    end
  end
end
