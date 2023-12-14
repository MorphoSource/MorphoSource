module Morphosource
  module Collections
    module OrganizationCollections
      class DeviceMediaSearchBuilder < Morphosource::Collections::OrganizationCollections::MediaSearchBuilder

        def organization_fields
          ['media_device_facility_organization_id_ssim']
        end

      end
    end
  end
end