# frozen_string_literal: true

class Organization < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  validates_with Morphosource::ParentChildValidator

  self.indexer = OrganizationIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = [Device]

  validates :title, presence: { message: 'Your work must have a title.' }

  include Morphosource::OrganizationMetadata
  include Morphosource::PermissionsDefaultsMetadata

  # TODO: investigate why this doesn't work w/ index_related_works
  before_update :record_original_team
  after_create :index_related_works

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  def specimens
    BiologicalSpecimen.where(organization_id_tesim: id)
  end

  def cultural_heritage_objects
    CulturalHeritageObject.where(organization_id_tesim: id)
  end

  def physical_objects
    specimens + cultural_heritage_objects
  end

  # Specimens that belong to the organization, but are not part of the liked team's items.
  def outside_specimens
    outside_team(specimens)
  end

  def media
    physical_objects.map { |obj| obj.descendants.select { |d| d.class == Media } }.flatten
  end

  def objects
    ActiveFedora::Base.find(member_ids)
  end

  # Media that belong to specimens owned by the organization, but are not part of the liked team's items.
  def outside_media
    outside_team(media)
  end

  def team
    return nil if team_id.empty?

    Collection.find(team_id.first)
  end

  # TODO: investigate why this doesn't work w/ index_related_works
  def record_original_team
    return nil if !team_id_changed?

    @old_collections = ActiveFedora::Base.where("linked_organization_id_ssi:#{id}")
  end

  private

    def outside_team(works)
      works.select { |w| !w.member_of_collections.include? team }
    end
end
