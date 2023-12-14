module Morphosource
  class DeviceMediaSearchBuilder < Morphosource::PhysicalObjectMediaSearchBuilder

    include Morphosource::OrganizationalAccessBehavior

    self.object_id_field = 'media_device_id_ssim'

  end
end
