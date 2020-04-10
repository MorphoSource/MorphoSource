class Media < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  validates_with Morphosource::ParentChildValidator

  self.work_requires_files = true

  self.indexer = MediaIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = [ProcessingEvent, Attachment]

  validates :title, presence: { message: 'Your work must have a title.' }

  attr_accessor :download_permission

  include Morphosource::MediaMetadata
  include Morphosource::PermissionsDefaultsMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  def self.parent_works(work)
    if work.in_works.empty?
      return []
    else
      return work.in_works.reject{|w| w.class == self}.map{|w| self.parent_works(w)}.flatten + work.in_works
    end
  end

  # array of all visibilities that apply to the file sets of a Media work
  # used to populate File Visibility column in dashboard works list
  def file_set_visibilities

    all_visibilities = [
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED,
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO,
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_LEASE,
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE ]

    file_visibilities = []

    file_sets.each do |file|
      if file.embargo&.active?
        file_visibilities << Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO
      elsif file.lease&.active?
        file_visibilities << Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_LEASE
      else
        file_visibilities << file.visibility
      end
    end
    # order unique visibilities in the order that they appear on the work form.
    all_visibilities & file_visibilities
  end

  # after media are migrated next round, should all have fileset_accessibility
  def restricted?
    return false if !fileset_accessibility.first
    fileset_accessibility.first == "restricted_download"
  end

  # after media are migrated next round, should all have fileset_accessibility
  def open?
    return true if !fileset_accessibility.first
    fileset_accessibility.first == "open"
  end

  def publication_status
    accessibility = fileset_accessibility.first
    case
    when accessibility == "open"
      "open"
    when accessibility == "restricted_download"
      "restricted"
    when accessibility == "preview_only"
      "preview"
    when accessibility == "hidden"
      "hidden"
    when accessibility == "private"
      "private"
    when under_embargo?
      "embargo"
    when active_lease?
      "lease"
      #TODO: remove after migrated media have fileset_accessibility values
    when accessibility == "" || accessibility == nil
      "open"
    end
  end

  def specimens
    ancestors.select(&:specimen?)
  end

  def organizations
    specimens.each_with_object([]) do |s, orgs|
      s.organizations.each { |o| orgs << o }
    end
  end

  def organizations_teams
    organizations.each_with_object([]) do |org, teams|
      teams += Collection.find(org.team_id.first)
    end
  end

  private
    def add_id_to_title
      unless self.title && self.id && self.title.first.to_s.start_with?("M#{self.id.to_s}: ")
        self.title.set("M#{self.id.to_s}: #{self.title.first.to_s}")
      end
    end
end
