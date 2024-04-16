# Generated via
#  `rails generate hyrax:work Device`
class Device < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  include Morphosource::PersistentIdentifiersBehavior
  validates_with Morphosource::ParentChildValidator
  after_create :mint_ark
  after_save :update_organization_access
  after_update :update_ark_status
  after_destroy :delete_ark_if_reserved

  self.indexer = DeviceIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = []

  validates :title, presence: { message: 'Your device must have a model name.' }

  include Morphosource::DeviceMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  def organization
    organization_id.present? ? ActiveFedora::Base.find(organization_id.first) : member_of.select { |m| m.class == Organization || m.class == OrganizationCollection }&.first
  end

  private

  def update_organization_access
    # if the organization_id has changed, remove the old org groups
    if ( attribute_changed?(:organization_id) &&
         old_organization_id = attribute_was(:organization_id)&.first )
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
