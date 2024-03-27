module Morphosource
  module Solr
    module Device
      def device_organization_title
        self['device_organization_title_tesim']
      end

      def device_organization_institution_name
        self['device_organization_institution_name_tesim']
      end

      def ark
        self["ark_tesim"]
      end
    end
  end
end