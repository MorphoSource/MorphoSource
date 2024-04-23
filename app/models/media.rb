class Media < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  include Morphosource::MediaBehavior
  include Morphosource::PersistentIdentifiersBehavior
  validates_with Morphosource::ParentChildValidator
  before_create :controlled_value_filter, :date_filter
  after_create :mint_ark
  before_update :record_original_member_of_public_collection_ids, :record_original_related_media_ids, :controlled_value_filter, :date_filter
  before_validation :normalize_download_reviewer
  after_update :update_ark_status, :update_cartitem_reviewer, :check_for_organization_transfer
  before_destroy :record_original_objects
  after_destroy :reindex_physical_objects

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
  after_destroy :delete_ark_if_reserved, :delete_fund_code_media_associations

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

  def is_remote_backed?
    self.remote_origin_url&.match(/^https?:\/\//).present?
  end

  def has_remote_manifest?
    remote_manifest_url.present?
  end

  def file_origin
    return "" unless self.file_sets.present?
    return (is_remote_backed? ? "Remote" : "Local")
  end

  def set_remote_file_health
    return unless self.is_remote_backed?
    issues = Morphosource::RemoteFileVerificationService.call(self)
    if issues.empty?
      status = "Ok"
      details = "None"
    else
      status = "Problematic"
      details = issues.join('; ')
    end

    if (health = RemoteFileHealth.where(media: self.id)&.first).present?
      health.update({
        status: status,
        details: details
      })
      health.touch
    else
      RemoteFileHealth.create({
        media: self.id,
        status: status,
        details: details
      })
    end
  end

  def remote_file_health_details
    return "" unless self.is_remote_backed?
    return "" unless (health = RemoteFileHealth.where(media: self.id, status: "Problematic")&.first).present?
    return health.details
  end

  def cart_items
    CartItem.where(work_id: id)
  end

  def normalize_download_reviewer
    self.download_reviewer = self.download_reviewer.map { |x| x.split(',') }.flatten
  end

  # Generate a formatted Media work title from work attributes, using part, media_type, and modality
  #
  # @return [String] formatted title
  def generate_title_from_attributes
    parts = part.presence || ['Element unspecified']
    media_type_first = media_type&.first.presence || ''
    modality_abbrevs = (imaging_event&.ie_modality || []).
      map { |m| Morphosource::ModalitiesService.abbreviation(m) }

    parts.sort.join(', ').titleize +
      (media_type_first.presence ? ' [' + media_type_first.to_s + ']' : '') +
      (modality_abbrevs.presence ? ' [' + modality_abbrevs.join('/')+ ']' : ' [Etc]')
  end

  def human_readable_media_type
    [Morphosource::MediaTypesService.short_term(media_type&.first) || "Unknown Type"]
  end

  def modality
    imaging_event&.ie_modality&.first
  end

  def modality_label
    Morphosource::ModalitiesService.label(imaging_event&.ie_modality&.first) || ""
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

    # check to make sure the media is not destroyed before indexing is done
    if file_sets&.first&.parent.present?
      file_sets.each do |file|
        if file.embargo&.active?
          file_visibilities << Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO
        elsif file.lease&.active?
          file_visibilities << Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_LEASE
        else
          file_visibilities << file.visibility
        end
      end
    end
    # order unique visibilities in the order that they appear on the work form.
    all_visibilities & file_visibilities
  end

  # true if nil, [], [''] unless under lease or embargo
  def fileset_accessibility_not_set
    return false if under_embargo?
    return false if active_lease?
    return true if fileset_accessibility.blank?
    return true if fileset_accessibility.first.blank?
    false
  end

  # Update media publication status, optionally saving Media and any Media FileSets
  #
  # @param status [String] new publication status code (one of "open", "restricted", "private")
  # @raise [ValueError] when publication status is not found in publication statuses authority
  def update_publication_status(status, save_media = true, save_file_set = true)
    qa_status_service = Morphosource::Qa::PublicationStatusesService.new
    qa_entry = qa_status_service.authority.find(status)
    new_visibility = qa_entry[:visibility]
    new_accessibility = qa_entry[:accessibility]

    if new_visibility && new_accessibility
      return if visibility == new_visibility && fileset_accessibility == [new_accessibility]

      self.visibility = new_visibility
      self.fileset_accessibility = [new_accessibility]
      self.save! if save_media

      file_sets.each do |file_set|
        file_set.visibility = new_visibility
        file_set.accessibility = [new_accessibility]
        file_set.save! if save_file_set
      end

      InheritPermissionsJob.perform_later(id) if save_media
    else
      raise ValueError "No publication status ID #{status} found in publication statuses authority"
    end

  end

  def owner_class
    User.find_by(ms_id: self.owner)&.class || OrganizationCollection.find_by(id: self.owner)&.class
  end

  #
  # Methods for related works and related work attributes
  #

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

  def media_parent
    ancestor_find(:media?)
  end

  def media_parents
    ancestors.select(&:media?)
  end

  def media_children
    descendants.select(&:media?)
  end

  def is_raw?
    processing_event.nil?
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

    qry = "#{ActiveFedora.index_field_mapper.solr_name('imaging_event_id', :stored_searchable)}:#{imaging_event.id} AND has_model_ssim:Media"
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

  def organizations_team_ids
    organizations.map { |org| org.team_id&.first }.compact
  end

  def taxonomies
    physical_objects.select {|po| po.class == BiologicalSpecimen }.map(&:taxonomies).flatten
  end

  def taxonomies_titles
    taxonomies.map{ |t| t.title.first }
  end

  #
  # Collection membership methods
  #

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

  def member_of_media_lists
    member_of_collections.select { |c| c.media_list? }
  end

  def member_of_media_list_ids
    member_of_media_lists.map(&:id)
  end

  def member_of_sequential_section_lists
    member_of_collections.select { |c| c.sequential_section_list? }
  end

  def member_of_sequential_section_list_ids
    member_of_sequential_section_lists.map(&:id)
  end

  #
  # Persistent identifier methods
  #

  def mint_doi(target_url)
    if self.doi.empty?
      depositor_user = User.find_by(ms_id: self.user_with_ownership)
      depositor_user_name_components = depositor_user.display_name.split(' ')
      minted_doi = Morphosource::CrossrefDoiMinter.mint_doi( self.id,
                                                            {'title' => self.title.first,
                                                             'author_first' => depositor_user_name_components.first,
                                                             'author_last' => depositor_user_name_components.drop(1).join(' '),
                                                             'url' => target_url,
                                                             'resource_type' => self.media_type.first} )
      if minted_doi.present?
        # minted_doi may be an exception if mint_doi failed
        unless minted_doi.respond_to?(:message)
          self.doi = [minted_doi]
          self.save
        end
      end
      return minted_doi
    end
  end

  #
  # Methods for persisting and monitoring save around work updates
  #

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

  #
  # Fund Code Methods
  #

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

  def active_fund_code_title
    active_fund_code_association&.title || "MorphoSource"
  end

  def update_cartitem_reviewer
    if self.download_reviewer_changed?
      UpdateCartItemReviewersJob.perform_later(self)
    end
  end

  def check_for_organization_transfer
    if ( self.visibility_changed? &&
         self.visibility == 'open' &&
         self.organization_transfer_on_publish )
      transfer_media_to_organization
    end
  end

  #
  # Temporary View Access Link methods
  #

  def temporary_links
    TemporaryMediaAccessLink.where(media_id: id)
  end

  def active_temporary_links
    temporary_links.where('expires_at > ?', DateTime.now)
  end

  #
  # Organization media transfer
  #

  # TODO: Refactor when organization collections have been implemented on production.
  def transfer_media_to_organization
    org = organizations&.first
    case org
    when Organization
      transfer_media_to_organizational_team(org)
    when OrganizationCollection
      transfer_media_to_organization_collection(org)
    end
  end

  # TODO: Remove when organization collections have been implemented on production
  # Create request to transfer ownership of media and/or move media to organization team or collection
  # generally, don't use this for where media data manager == org data manager,
  # but the method can handle this circumstance for use in developer console, etc
  def transfer_media_to_organizational_team(org)
    if (
      org.present? &&
      (new_manager_id = org&.data_manager&.first).present? &&
      (new_manager = User.find_by_user_key(new_manager_id)).present?
    )
      # First, is media manager user the same as the new org data manager?
      if ( new_manager.user_key == user_with_ownership || new_manager.user_key == on_behalf_of )
        # don't create transfer, but add media to team and ensure no further transfers are created
        add_to_organization_team
        if self.organization_transfer_on_publish
          self.organization_transfer_on_publish = false
          self.save!
        end
      else
        # create transfer, when accepted it will move media to team
        create_new_organization_transfer_request(new_manager)
      end
    else
      message = "Failed to transfer management of media #{id} to organization #{org&.id} with data manager #{org&.data_manager}"

      Rails.logger.fatal message
      raise message
    end
  end

  def transfer_media_to_organization_collection(org)
    # check that organization has a valid data manager
    if org.managers&.first.present?
      if self.organization_transfer_on_publish
        self.organization_transfer_on_publish = false
        self.save!
      end
      create_new_organization_transfer_request(org)
    else
      message = "Failed to transfer management of media #{id} to organization #{org&.id}"

      Rails.logger.fatal message
      raise message
    end
  end

  def add_to_organization_team
    if (org = organizations&.first).present? && (team = org.team).present?
      AddCollectionMembersJob.perform_later(team.id, id)
    end
  end

  def create_new_organization_transfer_request(org_data_manager, force_update=false)
    # Cancel existing pending proxy deposit requests
    if (existing_transfers = ProxyDepositRequest.where(work_id: id, status: 'pending')).present?
      if force_update
        existing_transfers.each { |t| t.force_cancel! }
      else
        existing_transfers.each { |t| t.cancel! }
      end
    end
    # Create new proxy deposit request from user with ownership to organization
    message = I18n.t('morphosource.media.organization_transfer.transfer_message').html_safe
    ProxyDepositRequest.create!(
      work_id: id,
      receiving_user: org_data_manager,
      sending_user: User.find_by_user_key(user_with_ownership),
      sender_comment: message,
      organization_transfer: true
    )
  end

  # keeping external file methods for now, but these will be deleted once Simon's remote file changes are incorporated.
  def external_file?
    file_sets&.first&.external_file.present?
  end

  def external_file
    file_sets&.first&.original_file&.external_file
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

    def delete_fund_code_media_associations
      FundCodeMediaAssociation.where(media: self.id).each { |a| a.destroy! }
    end

    def record_original_objects
      @objects = physical_objects
    end

    # removes destroyed media id from related_media_ids_ssim
    def reindex_physical_objects
      @objects.each do |obj|
        UpdateWorkIndexJob.perform_later(obj.id)
      end
    end

    def date_attributes_for_filter
      [ :date_created ]
    end

    def controlled_attributes
      {
        :media_type => Morphosource::MediaTypesService.new,
        :side => Morphosource::SidesService.new,
        :series_type => Morphosource::SeriesTypesService.new,
        :unit => Morphosource::UnitsService.new,
        :map_type => Morphosource::MapTypesService.new
      }
    end

end
