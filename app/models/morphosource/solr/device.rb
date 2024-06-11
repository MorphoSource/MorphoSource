module Morphosource
  module Solr
    module Device
      def device_organization_id
        self['device_organization_id_tesim']
      end

      def device_organization_title
        self['device_organization_title_tesim']
      end

      def device_organization_institution_name
        self['device_organization_institution_name_tesim']
      end
    end
  end
end