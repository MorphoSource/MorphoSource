# frozen_string_literal: true

class Organization < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  validates_with Morphosource::ParentChildValidator

  self.indexer = OrganizationIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = [Device, BiologicalSpecimen, CulturalHeritageObject]

  validates :title, presence: { message: 'Your work must have a title.' }

  include Morphosource::OrganizationMetadata
  include Morphosource::PermissionsDefaultsMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  before_update :save_old_values
  after_save :update_team_index, :update_media_index, :update_object_index

  def specimens
    ActiveFedora::Base.find(member_ids).select { |m| m.class == BiologicalSpecimen }
  end

  def objects
    ActiveFedora::Base.find(member_ids).select { |m| m.physical_object? }
  end

  # Specimens that belong to the organization, but are not part of the liked team's items.
  def outside_specimens
    outside_team(specimens)
  end

  def media
    descendants.select { |d| d.class == Media }
  end

  # Media that belong to specimens owned by the organization, but are not part of the liked team's items.
  def outside_media
    outside_team(media)
  end

  def team
    Collection.find(team_id.first)
  end

  private

    def update_team_index
      if @old_team_id
        @old_team = Collection.find(@old_team_id)
        @old_team.update_index
        @old_team.child_projects.each(&:update_index)
      end
      unless team_id.blank?
        team.update_index
        team.child_projects.each(&:update_index)
      end
    end

    def update_media_index
      media.each(&:update_index)
    end

    def update_object_index
      object_ids = old_object_ids | member_ids
      return if object_ids.blank?

      objects = ActiveFedora::Base.find(object_ids)
      objects&.each(&:update_index)
    end

    def old_object_ids
      org_name = "\"#{title.first}\""
      object_ids =
      ActiveFedora::SolrService.query(["organization_tesim:#{org_name}"], rows: 999999).map(&:id)
    end

    def save_old_values
      if team_id_previously_changed?
        @old_team_id = team_id_previous_change.first.first
      end
    end

    def outside_team(works)
      works.select { |w| !w.member_of_collections.include? team }
    end
end
