# Retrieves all media a user can edit or has been granted read access to through a role (collection members group)
module Morphosource
  module Users
    class MySpecimensSearchBuilder < Hyrax::WorksSearchBuilder

      # include Hyrax::My::SearchBuilderBehavior

      self.default_processor_chain += [:apply_specimen_ids_filter]

      def models
        [BiologicalSpecimen]
      end

      private

      def apply_specimen_ids_filter(solr_parameters)
        solr_parameters[:fq] ||= []
        byebug
        solr_parameters[:fq] << specimen_ids_filter.reject(&:blank?).join(' OR ')
      end

      def specimen_ids_filter
        object_ids = ["000202892"]
        ["({id:(#{object_ids.join(' OR ')})})"]
      end

      # def all_member_media_objects(object_ids = [], object_model = nil, fq_params = [])
      #   core_fq = "(id:(#{object_ids.join(' OR ')}))"
      #   core_fq += " AND (#{Solrizer.solr_name('has_model', :symbol)}:#{object_model})" if object_model.present?
      #   fq_params << core_fq
      #   available_member_works_filter_query(fq_params: fq_params, object_model: object_model)
      # end

    end
  end
end
