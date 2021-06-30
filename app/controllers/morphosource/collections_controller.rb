module Morphosource
  class CollectionsController < Hyrax::CollectionsController

    # include TeamsControllerBehavior

    include Hydra::Catalog
    include Hyrax::Collections::AcceptsBatches
    include Blacklight::Configurable

    include Morphosource::CollectionsControllerBehavior
    helper Morphosource::CollectionHelper

    with_themed_layout 'morphosource_1_column'

    load_and_authorize_resource except: [:index, :show, :create, :media], instance_name: :collection


    # helper_method :hidden_params_for_filters, :hidden_params_for_pagination, :publication_status_label,
    #   :media_type_label, :filter_params, :ms_collection_view_link, :source_label, :bso_tab_url_for_collections,
    #   :cho_tab_url_for_collections, :page_is_team?, :showpage_url, :ms_collection_view_link, :ms_collection_view_link_qs,
    #   :origin_label
    #
    # load_and_authorize_resource except: [:index, :show, :specimens, :chos, :create], instance_name: :collection

    # Hyrax version
    # load_and_authorize_resource except: [:index, :show, :create], instance_name: :collection

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
  end
end
