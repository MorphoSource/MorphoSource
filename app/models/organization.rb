# frozen_string_literal: true

class Organization < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  include Morphosource::OrganizationBehavior
  validates_with Morphosource::ParentChildValidator

  before_validation :normalize_download_reviewer

  self.indexer = OrganizationIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = [Device]

  validates :title, presence: { message: 'Your work must have a title.' }

  include Morphosource::OrganizationMetadata
  include Morphosource::PermissionsDefaultsMetadata
  include Morphosource::LocationMetadata

  # TODO: investigate why this doesn't work w/ index_related_works
  before_update :record_original_team
  after_create :index_related_works

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  def normalize_download_reviewer
    self.download_reviewer = self.download_reviewer.map { |x| x.split(',') }.flatten
  end

  def devices
    members.select { |m| m.device? }
  end

  # Specimens that belong to the organization, but are not part of the liked team's items.
  def outside_specimens
    outside_team(specimens)
  end

  # Media that belong to specimens owned by the organization, but are not part of the liked team's items.
  def outside_media
    outside_team(media)
  end

  def team
    return nil if team_id.empty?

    Collection.find(team_id.first)
  end

  # for compatibility with organization collections
  def media_ownership_transfer; end

  # TODO: investigate why this doesn't work w/ index_related_works
  def record_original_team
    return nil if !team_id_changed?

    @old_collections = ActiveFedora::Base.where("linked_organization_id_ssi:#{id}")
  end

  # Custom method to handle CarrierWave uploader
  def agreement_uploader
    @agreement_uploader ||= OrganizationAgreementAttachmentUploader.new.tap { |u| u.work_id = id }
  end

  private

    def outside_team(works)
      works.select { |w| !w.member_of_collections.include? team }
    end
end
