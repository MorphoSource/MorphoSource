# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource DeviceResource`
class DeviceResource < Hyrax::Work
  include Hyrax::Schema(:basic_metadata)
  include Hyrax::Schema(:device_resource)

  delegate :download_groups, :download_groups=,
           :download_users,  :download_users=, to: :permission_manager

  include Morphosource::PersistentIdentifiersBehavior

  def organization
    organization_id.present? ? ActiveFedora::Base.find(organization_id.first) : nil
  end

  def media_docs
    Morphosource::SolrService.new.get_docs("has_model_ssim:Media AND media_device_id_ssim:#{id}")
  end

  def media
    Media.where("media_device_id_ssim" => id)
  end
end
