module Morphosource
  module My
    module WorksHelper

      def active_tab?(tab)
        @tab == tab ? 'active' : ''
      end

      def search_action_for_dashboard
        case params[:controller]
        when "hyrax/my/collections"
          hyrax.my_collections_path
        when "hyrax/my/shares"
          hyrax.dashboard_shares_path
        when "hyrax/my/highlights"
          hyrax.dashboard_highlights_path
        when "hyrax/dashboard/works"
          hyrax.dashboard_works_path
        when "hyrax/dashboard/collections"
          hyrax.dashboard_collections_path
        when "morphosource/my/media"
          main_app.my_media_index_path
        else
          # hyrax/my/works controller and default cases.
          hyrax.my_works_path
        end
      end

      def total_viewable_media(id)
        ActiveFedora::Base.where("physical_object_id_tesim:#{id} AND has_model_ssim:Media").accessible_by(current_ability).count
      end

      # def collection_title_by_id(id)
      #   test = ActiveFedora::SolrService.query("id:#{id}", rows: 100000000)
      #   collection = ActiveFedora::Base.where("id:#{id}").accessible_by(current_ability)
      #   byebug
      #   return nil if collection.empty?
      #   solr_field = collection.first.title
      #   return nil if solr_field.nil?
      #   solr_field.first
      # end

      # def collection_title_by_id(id)
      #   solr_docs = controller.repository.find(id).docs
      #   return nil if solr_docs.empty?
      #   solr_field = solr_docs.first["title_tesim"]
      #   return nil if solr_field.nil?
      #   solr_field.first
      # end

      def collection_title_by_id(id)
        solr_docs = controller.repository.find(id).docs
        return nil if solr_docs.empty?
        collection = solr_docs.first
        solr_field = collection["title_tesim"]
        if collection['visibility_ssi'] == "restricted"
          byebug
          return nil unless current_ability.can? :read, collection
        end
        byebug
        return nil if solr_field.nil?
        solr_field.first
      end
    end
  end
end
