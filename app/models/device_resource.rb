# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource DeviceResource`
class DeviceResource < Hyrax::Work
  include Hyrax::Schema(:basic_metadata)
  include Hyrax::Schema(:device_resource)

  delegate :download_groups, :download_groups=,
           :download_users,  :download_users=, to: :permission_manager

## see https://elrayle.github.io/samvera_docs/valkyrie-work-extra-model-code.html for dealing with extra code

#  include ::Hyrax::WorkBehavior
  include Morphosource::PersistentIdentifiersBehavior

## validations will be handled with change sets  

#  validates_with Morphosource::ParentChildValidator
#  after_create :mint_ark
#  after_save :update_organization_access
#  after_update :update_ark_status
#  after_destroy :delete_ark_if_reserved

#  self.indexer = DeviceIndexer
  # Change this to restrict which works can be added as a child.
#  self.valid_child_concerns = []

#  validates :title, presence: { message: 'Your device must have a model name.' }

  def organization
    organization_id.present? ? ActiveFedora::Base.find(organization_id.first) : member_of.select { |m| m.class == Organization || m.class == OrganizationCollection }&.first
  end

  def media_docs
    Morphosource::SolrService.new.get_docs("has_model_ssim:Media AND media_device_id_ssim:#{id}")
  end

  def media
    Media.where("media_device_id_ssim" => id)
  end

  private

  def update_organization_access
    # if the organization_id has changed, remove the old org groups
    if (
      attribute_changed?(:organization_id) &&
      old_organization_id = attribute_was(:organization_id)&.first
    )
      self.edit_groups -= ["#{old_organization_id}_managers", "#{old_organization_id}_editors"]
    end
    # add the current organization groups
    return if organization_id.blank?

    organization_groups = ["#{organization_id.first}_managers", "#{organization_id.first}_editors"]
    unless (self.edit_groups & organization_groups).sort == organization_groups.sort
      self.edit_groups += organization_groups
      self.update_index
    end
  end
end
