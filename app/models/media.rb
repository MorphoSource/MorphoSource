class Media < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  validates_with Morphosource::ParentChildValidator
  after_create :mint_ark
  before_update :record_original_member_of_public_collection_ids, :record_original_related_media_ids
  before_validation :normalize_download_reviewer
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
    User.where(ms_id: download_reviewer.to_a).map { |u| u.ms_id.present? ? u.ms_id : nil }.compact.presence || [user_with_ownership]
  end

  def normalize_download_reviewer
    self.download_reviewer = self.download_reviewer.map { |x| x.split(',') }.flatten
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

  def private?
    publication_status == "private"
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
    physical_objects.select(&:specimen?)
  end

  def cultural_heritage_objects
    physical_objects.select(&:cho?)
  end

  def object_titles
    physical_objects.map(&:title)
  end

  def object_title
    object_titles&.flatten&.first&.first
  end

  def physical_objects
    ancestors.select(&:imaging_event?).map(&:objects).flatten
  end
  alias objects physical_objects

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

  def processing_event
    ancestors.find(&:processing_event?)
  end

  def child_media
    descendants.select { |d| d.class == Media }
  end

  def child_media_ids
    child_media&.map{ |o| o.id }
  end

  def related_media
    return [] unless imaging_event.present?
    imaging_event.descendants.select { |d| d.class == Media && d.id != self.id}
  end

  def related_media_ids
    related_media.map{ |o| o.id }
  end

  def related_media_ids_solr
    related_media_solr.map { |d| d['id'] }.reject { |id| id == self.id }
  end

  def related_media_solr
    return [] if !imaging_event.present? || !imaging_event&.id.present?

    qry = "#{Solrizer.solr_name('imaging_event_id', :stored_searchable)}:#{imaging_event.id} AND has_model_ssim:Media"
    ::Morphosource::SolrService.new().get_docs(qry, args: { fl: 'id' } )
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
    physical_objects.select {|po| po.class == BiologicalSpecimen }.map(&:taxonomies).flatten
  end

  def taxonomies_titles
    taxonomies.map{ |t| t.title.first }
  end

  def member_of_teams
    member_of_collections.select { |c| c.team? }
  end

  def member_of_team_ids
    member_of_teams.map(&:id)
  end

  def member_of_projects
    member_of_collections.select { |c| c.project? } 
  end

  def member_of_project_ids
    member_of_projects.map(&:id)
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

  def record_original_member_of_public_collection_ids
    @original_member_of_public_collection_ids = member_of_public_collection_ids
  end

  def member_of_public_collection_ids_changed?
    @original_member_of_public_collection_ids.sort != member_of_public_collection_ids.sort
  end

  def record_original_related_media_ids
    @original_related_media_ids = related_media_ids
  end

  def related_media_ids_changed?
    @original_related_media_ids.sort != related_media_ids.sort
  end

  # Fund Code Methods

  def fund_code_associations
    FundCodeMediaAssociation
      .joins(:fund_code)
      .select('fund_code_media_associations.*, fund_codes.title, fund_codes.description')
      .where(media: id)
  end

  def fund_codes
    FundCode
      .joins(:fund_code_media_associations)
      .where(fund_code_media_associations: { media: id })
  end

  def new_fund_code_association(fund_code)
    return nil if fund_codes.where(id: fund_code.id).present?
    fcma = FundCodeMediaAssociation.new(fund_code: fund_code, media: id, active: true).save!
    return fcma
  end

  def active_fund_code_association
    fund_code_associations.where(active: true)&.first
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
