module Morphosource
  class CollectionsController < Hyrax::CollectionsController
    include Morphosource::CollectionsControllerBehavior
    helper Morphosource::CollectionHelper
    include Morphosource::Facets::Collections
    include Morphosource::TemporaryAccess::View::CollectionsTemporaryLinkViewControllerBehavior
    include Morphosource::TemporaryAccess::Authorize::CollectionsControllerBehavior

    with_themed_layout 'morphosource_1_column'

    skip_load_and_authorize_resource only: [
      :show, :about, :facet,
      :media_export, :media_downloads, :media_download_counts, :media_requests
    ], instance_name: :collection
    prepend_before_action :authorize_with_temporary_link, only: [:show, :about]

    # Don't add breadcrumbs
    before_action :build_breadcrumbs, only: []

    before_action :load_collection, :redirect_to_collection_type

    class_attribute :can_authorize_with_temporary_link
    self.can_authorize_with_temporary_link = false
    self.presenter_class = presenter_class


    def search_builder_class
      Morphosource::Collections::MediaSearchBuilder
    end

    def self.remove_bookmarks
      configure_blacklight do |config|
        config.index.document_actions.delete(:bookmark)
        config.show.document_actions.delete(:bookmark)
      end
    end
    remove_bookmarks

    def media_export_with_intersections_facet
      media_export
    end

    def media_download_counts_with_intersections_facet
      media_download_counts
    end

    private

      def decide_layout
        layout = case action_name
                when 'show'
                  'morphosource_1_column'
                else
                  'dashboard'
                end
        File.join(theme, layout)
      end

      def sort_parameters
        s = (params[:sort].presence || '').split(' ')
        return s[0], s[1]
      end
      helper_method :sort_parameters

      def authorize_with_temporary_link
        return unless self.can_authorize_with_temporary_link
        if params[:token].present?
          # user accessing project via temporary link URL, auth and set cookie if needed
          load_temporary_access_link
          authorize_temporary_access_link
          load_curation_concern
          authorize_curation_concern
          set_authorization_cookie
          flash[:notice] = I18n.t('morphosource.collections.view.temporary_access', collection_type: 'project')
        elsif params[:id].present? && temporary_link_cookie_exists?(params[:id]) && !current_ability.can?(:read, params[:id])
          # user has pre-existing cookie and can't otherwise access project
          authorize_with_temporary_link_if_present(params[:id])
          flash[:notice] = I18n.t('morphosource.collections.view.temporary_access', collection_type: 'project')
        end
      end
  end
end
