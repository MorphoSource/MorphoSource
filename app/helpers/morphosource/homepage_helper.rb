module Morphosource
  module HomepageHelper

    def featured_projects
      project_ids = Rails.application.config.featured_project_ids
      if project_ids.blank?
        collections
      else
        projects = project_ids.each_with_object([]) do |id, projects|
          projects << ::SolrDocument.where("id:#{id} AND collection_type_gid_ssim:*")&.first
        end
        projects.compact.empty? ? collections : projects.compact
      end
      rescue
      collections
    end

    private

    # Return 6 collections
     def collections(rows: 6)
       builder = Hyrax::CollectionSearchBuilder.new(self).rows(rows)
       config = CollectionsCatalogController.blacklight_config
       response = Blacklight::Solr::Repository.new(config).search(builder)
       response.documents
     rescue Blacklight::Exceptions::ECONNREFUSED, Blacklight::Exceptions::InvalidRequest
       []
     end
  end
end
