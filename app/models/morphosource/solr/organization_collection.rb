module Morphosource
  module Solr
    module OrganizationCollection

      def organization_collection?
        self['has_model_ssim'] == ['OrganizationCollection']
      end

      def organization_type
        self['organization_type_ssim']
      end

      def collection_code
        self['collection_code_ssim']
      end

      def institution_code
        self['institution_code_ssim']
      end

      def institution_name
        self['institution_name_ssim']
      end

      def recordset_id
        self['recordset_id_ssim']
      end

      def display_name
        self['display_name_ssi']
      end

    end
  end
end
