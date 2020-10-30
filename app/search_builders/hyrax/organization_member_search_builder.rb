module Hyrax
  class OrganizationMemberSearchBuilder < ::SearchBuilder
    include Hyrax::FilterByType
    attr_reader :search_includes_models

#    self.default_processor_chain += [:member_of_collection]

    def initialize(scope:,
                   search_includes_models: :works)
      @search_includes_models = search_includes_models
      super(scope)
    end

    # include filters into the query to only include the collection memebers
#    def member_of_collection(solr_parameters)
#      solr_parameters[:fq] ||= []
#      collection_ids = []
#      collections.each do |collection_doc|
#        collection_ids << collection_doc.id
#      end
#      #solr_parameters[:fq] << "#{collection_membership_field}:#{collection.id}"
#      solr_parameters[:fq] << "#{collection_membership_field}:(#{collection_ids.join(' OR ')})"
#    end

    # This overrides the models in FilterByType
    def models
#      case search_includes_models
#      when :collections
#        collection_classes
#      when :works
        work_classes
#      else super # super includes both works and collections
#      end
    end
  end
end
