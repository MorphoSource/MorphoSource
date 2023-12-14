module Morphosource
  module Collections
    module OrganizationCollections
      class MediaSearchBuilder < Morphosource::Collections::MediaSearchBuilder

        # organization collection members can view media associated with objects or devices from the organization
        include Morphosource::OrganizationalAccessBehavior

        self.default_processor_chain -= [:member_of_collection]
        self.default_processor_chain += [:apply_organization_filters]

        def apply_organization_filters(solr_parameters)
          solr_parameters[:fq] ||= []
          solr_parameters[:fq] << organization_filters.reject(&:blank?).join(' OR ')
          Rails.logger.debug("Solr parameters: #{solr_parameters.inspect}")
        end

        def organization_filters
          organization_fields.each_with_object([]) do |field, filters|
            filters << ["({!terms f=#{field}}#{collection.id})"]
          end
        end

        def organization_fields
          ['media_organization_id_ssim','media_device_facility_organization_id_ssim']
        end
      end
    end
  end
end