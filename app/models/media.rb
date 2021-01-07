class Media < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  validates_with Morphosource::ParentChildValidator
  after_create :mint_ark
  after_update :update_ark_status

  after_initialize do
    if self.new_record?
      self.preview_mode = Array.new(['Interactive/Embeddable'])
    end
  end

  self.work_requires_files = true

  self.indexer = MediaIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = [ProcessingEvent]

  validates :title, presence: { message: 'Your work must have a title.' }

  attr_accessor :download_permission, :tags, :delete_thumbnail, :generated_thumbnail
  before_destroy :prevent_doi_deletion
  after_destroy :delete_ark_if_reserved

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

  def cart_items
    CartItem.where(work_id: id)
  end

  def reviewer
    User.find_by(ms_id: download_reviewer.first).try(:ms_id) || user_with_ownership
  end

  def human_readable_media_type
    case media_type.first
    when "CTImageSeries"
      ["CT Image Series"]
    when "PhotogrammetryImageSeries"
      ["Photogrammetry Image Series"]
    else
      media_type
    end
  end

  def modality
    case imaging_event&.ie_modality&.first
    when "MicroNanoXRayComputedTomography"
      "X-Ray Computed Tomography (CT/microCT)"
    when "MagneticResonanceImaging"
      "Magnetic Resonance Imaging (MRI)"
    when "PositronEmissionTomography"
      "Positron Emission Tomography (PET)"
    when "SinglePhotonEmissionComputedTomography"
      "Single Photon Emission Computed Tomography (SPECT)"
    when "NeutronComputedTomography"
      "Neutron Computed Tomography (NCT)"
    when "SynchrotronImaging"
      "Synchrotron Imaging"
    when "Photogrammetry"
      "Photogrammetry"
    when "StructuredLight"
      "Structured Light"
    when "LaserScan"
      "Laser Scan"
    when "ConfocalImageStacking"
      "Confocal Image Stacking"
    when "Infrared"
      "Infrared"
    when "ReflectanceTransformationImaging"
      "Reflectance Transformation Imaging"
    when "Photography"
      "Photography"
    when "ScanningElectronMicroscopy"
      "Scanning Electron Microscopy"
    when "BornDigital"
      "Born Digital"
    when "XRay"
      "X-Ray"
    when "LaserAidedProfiling"
      "Laser Aided Profiling"
    when "Video"
      "Video"
    else
      imaging_event&.ie_modality&.first
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

  def restricted?
    publication_status == "restricted"
  end

  alias restricted_download? restricted?

  def open?
    publication_status == "open"
  end

  # true if publication status is open, restricted, lease
  def can_add_to_cart?
    case publication_status
    when 'open'
      true
    when 'lease'
      true
    when 'restricted'
      true
    else
      false
    end
  end

  # TODO - consider what happens with fileset_accessibility for lease/embargo
  def publication_status
    return 'private' if fileset_accessibility_not_set
    access = fileset_accessibility.first
    case
    when under_embargo?
      "embargo"
    when active_lease?
      "lease"
    when access == "open"
      "open"
    when access == "restricted_download"
      "restricted"
    when access == "preview_only"
      "preview"
    when access == "hidden"
      "hidden"
    else
      "private"
    end
  end

  # true if nil, [], [''] unless under lease or embargo
  def fileset_accessibility_not_set
    return false if under_embargo?
    return false if active_lease?
    return true if fileset_accessibility.blank?
    return true if fileset_accessibility.first.blank?
    false
  end

  def specimens
    ancestors.select(&:specimen?)
  end

  def object_titles
    physical_objects.map(&:title)
  end

  def physical_objects
    ancestors.select(&:physical_object?)
  end

  def physical_object_id
    physical_objects.map(&:id)
  end

  def physical_object_type
    return if physical_objects.empty?
    object = physical_objects.first
    object.specimen? ? "Biological Specimen" : "Cultural Heritage Object"
  end

  def imaging_event
    ancestors.find(&:imaging_event?)
  end

  # this method get siblings IDs from parents 1 level above
  def sibling_media_ids
    # Find parent media: Media < ProcessingEvent < Media
    processing_events = parent_works.select { |w| w.class == ProcessingEvent }
    parent_media = []
    processing_events.each do |p|
      parent_media += p.parent_works.select { |w| w.class == Media }
    end
    # Find child media of each parent: Media > ProcessingEvent > Media
    child_media = []
    parent_media.each do |m|
      processing_events = m.child_works.select { |w| w.class == ProcessingEvent }
      processing_events.each do |p|
        child_media += p.child_works.select { |w| w.class == Media }
      end
    end
    # remove any duplicate IDs, and remove the current media id
    sibling_ids = child_media.map{ |o| o.id }.flatten.uniq - [self.id]
    return sibling_ids
  end

  def related_media_ids
    po_media = []
    physical_objects.each do |po|
      po_media += po.related_media_ids
    end
    parents = ancestors.select { |d| d.class == Media }.map{ |o| o.id }
    children = descendants.select { |d| d.class == Media }.map{ |o| o.id }
    return (po_media + parents + children + sibling_media_ids).uniq
  end

  def public_related_media_ids
    parents = ancestors.select { |d| d.class == Media and d.visibility == 'open' }.map{ |o| o.id }
    children = descendants.select { |d| d.class == Media and d.visibility == 'open' }.map{ |o| o.id }
    siblings = sibling_media_ids.select { |d| d.visibility == 'open' }.map{ |o| o.id }
    return (parents + children + sibling_media_ids).uniq
  end

  def organizations
    physical_objects.each_with_object([]) do |obj, orgs|
      obj.organizations.each { |org| orgs << org }
    end
  end

  def organization_id
    organizations.map{ |o| o.id }
  end

  def organization_titles
    organizations.map{ |o| o.title.first }
  end

  def organizations_teams
    organizations.each_with_object([]) do |org, teams|
      teams += Collection.find(org.team_id.first)
    end
  end

  def taxonomies
    ancestors.select{|work| work.class == Taxonomy}
  end

  def taxonomies_titles
    taxonomies.map{ |t| t.title.first }
  end

  def ark_resource_type
    # Valid ARK resource types:
    # 'Audiovisual', 'Collection', 'DataPaper', 'Dataset', 'Event', 'Image',
    # 'InteractiveResource', 'Model', 'PhysicalObject', 'Service', 'Software',
    # 'Sound', 'Text', 'Workflow', 'Other'
    # These are defined in resourceTypeGeneral in the DataCite Metadata Schema:
    # http://schema.datacite.org/meta/kernel-4.3/
    ark_resource_type_mappings = {
      'Video' => 'Audiovisual',
      'Mesh' => 'Image',
      'CTImageSeries' => 'Collection',
      'PhotogrammetryImageSeries' => 'Collection'
    }
    if ark_resource_type_mappings.key?(self.media_type.first)
      return ark_resource_type_mappings[self.media_type.first]
    else
      return self.media_type.first
    end
  end

  # possible ARK status changes:
  # - reserved->public
  # - public->unavailable
  # - unavailable->public
  def update_ark_status
    unless self.ark.empty?
      if self.fileset_accessibility_changed?
        ark_identifier = Ezid::Identifier.find(self.ark.first)
        file_visibility = self.fileset_accessibility.first
        public_visibilities = %w{open restricted_download preview_only hidden}
        if %w{reserved unavailable}.include?(ark_identifier.status) && public_visibilities.include?(file_visibility)
          ark_identifier.status = 'public'
          ark_identifier.save
        elsif (ark_identifier.status == 'public') && (!public_visibilities.include?(file_visibility))
          ark_identifier.status = 'unavailable'
          ark_identifier.save
        end
      end
    end
  end

  def mint_ark
    if self.ark.empty?
      %w{DEFAULT_SHOULDER USER PASSWORD TARGET_HOST}.each do |required_env_variable|
        if ENV["EZID_#{required_env_variable}"].blank?
          Rails.logger.error("Error minting ARK: #{required_env_variable} environment variable not set")
          return true
        end
      end
      depositor_user = User.find_by(ms_id: self.depositor)
      depositor_user_name_components = depositor_user.display_name.split(' ')
      # DataCite metadata expects creator in the form Lastname, Firstname
      datacite_creator = [depositor_user_name_components.drop(1).join(' '),depositor_user_name_components.first].join(', ')
      public_visibilities = %w{open restricted_download preview_only hidden}
      ark_status = public_visibilities.include?(self.fileset_accessibility) ? 'public' : 'reserved'
      ark_metadata = {'_status' => ark_status,
                      '_target' => Rails.application.routes.url_helpers.media_showcase_url(:host => ENV['EZID_TARGET_HOST'], id: self.id),
                      '_profile' => 'datacite',
                      'datacite.identifiertype' => 'ARK',
                      'datacite.creator' => datacite_creator,
                      'datacite.publisher' => 'MorphoSource.org',
                      'datacite.title' => self.title.first,
                      'datacite.publicationyear' => Time.now.year.to_s,
                      'datacite.resourcetypegeneral' => self.ark_resource_type
      }
      requested_ark = "#{ENV['EZID_DEFAULT_SHOULDER']}/#{self.id.sub(/^0*/,'')}"

      minted_ark = Ezid::Identifier.create(requested_ark, ark_metadata)
      unless minted_ark.nil?
        self.ark = [minted_ark.id]
        self.save
      end
      return true
    end
  end

  def mint_doi(target_url)
    if self.doi.empty?
      depositor_user = User.find_by(ms_id: self.depositor)
      depositor_user_name_components = depositor_user.display_name.split(' ')
      minted_doi = Morphosource::CrossrefDoiMinter.mint_doi( self.id,
                                                            {'title' => self.title.first,
                                                             'author_first' => depositor_user_name_components.first,
                                                             'author_last' => depositor_user_name_components.drop(1).join(' '),
                                                             'url' => target_url,
                                                             'resource_type' => self.media_type.first} )
      unless minted_doi.nil?
        self.doi = [minted_doi]
        self.save
      end
      return minted_doi
    end
  end

  private
    def add_id_to_title
      unless self.title && self.id && self.title.first.to_s.start_with?("M#{self.id.to_s}: ")
        self.title.set("M#{self.id.to_s}: #{self.title.first.to_s}")
      end
    end

    def prevent_doi_deletion
      unless self.doi.empty?
        throw(:abort)
      end
    end

    def delete_ark_if_reserved
      unless self.ark.empty?
        ark_identifier = Ezid::Identifier.find(self.ark.first)
        if ark_identifier.status == 'reserved'
          ark_identifier.delete
        end
      end
    end
end
