module Morphosource
  module Collections
    module OrganizationCollections
      class OrganizationMediaSearchBuilder < Morphosource::Collections::OrganizationCollections::MediaSearchBuilder

        def organization_fields
          ['media_organization_id_ssim']
        end

      end
    end
  end
end