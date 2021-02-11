module Hyrax
  class TeamsController < ApplicationController

    include TeamsControllerBehavior
    include BreadcrumbsForCollections
    include Morphosource::CollectionHelper
    helper_method :hidden_params_for_filters, :hidden_params_for_pagination, :publication_status_label,
      :media_type_label, :filter_params, :ms_collection_view_link, :source_label, :bso_tab_url_for_collections, 
      :cho_tab_url_for_collections, :page_is_team?, :showpage_url, :ms_collection_view_link, :ms_collection_view_link_qs,
      :origin_label

    with_themed_layout :decide_layout
    load_and_authorize_resource except: [:index, :show, :specimens, :chos, :create], instance_name: :collection

    # Renders a JSON response with a list of files in this collection
    # This is used by the edit form to populate the thumbnail_id dropdown
    def files
      result = form.select_files.map do |label, id|
        { id: id, text: label }
      end
      render json: result
    end

    private

      def form
        @form ||= form_class.new(@collection, current_ability, repository)
      end

      def decide_layout
        layout = case action_name
                 when 'show'
                   'morphosource_1_column'
                 else
                   'dashboard'
                 end
        File.join(theme, layout)
      end
  end
end