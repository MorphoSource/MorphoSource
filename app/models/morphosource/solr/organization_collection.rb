module Morphosource
  module Solr
    module OrganizationCollection

      def organization_collection?
        self['has_model_ssim'] == ['OrganizationCollection']
      end

    end
  end
end
