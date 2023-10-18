# Generated via
#  `rails generate hyrax:work Device`
class Device < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  validates_with Morphosource::ParentChildValidator

  self.indexer = DeviceIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = []

  validates :title, presence: { message: 'Your device must have a model name.' }

  include Morphosource::DeviceMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  def organization
    organization_id.present? ? ActiveFedora::Base.find(organization_id.first) : member_of.select { |m| m.class == Organization }&.first
  end
end
