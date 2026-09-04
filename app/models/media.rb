class Media < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  include Morphosource::MediaBehavior
  include Morphosource::PersistentIdentifiersBehavior
  include Morphosource::DoiBehavior
  include Morphosource::Works::ValkyrieAssociation

  validates_with Morphosource::ParentChildValidator
  before_create :controlled_value_filter, :date_filter
  after_create :mint_ark
  before_update :record_original_member_of_public_collection_ids, :record_original_related_media_ids, :controlled_value_filter, :date_filter
  before_validation :normalize_download_reviewer
  after_update :update_ark_status, :update_cartitem_reviewer, :check_for_organization_transfer
  after_update :publish_reviewers_updated
  before_destroy :prevent_doi_deletion
  before_destroy :record_original_objects
  after_destroy :reindex_physical_objects, :publish_destroyed_event

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
  # Set on the corpus-wide backfill so it does not publish one reviewer event per record.
  attr_accessor :skip_reviewer_event
  after_destroy :delete_ark_if_reserved, :delete_fund_code_media_associations

  include Morphosource::MediaMetadata
  include Morphosource::PermissionsDefaultsMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  validates :download_reviewer_mode, inclusion: { in: DOWNLOAD_REVIEWER_MODES }
  validate :object_organization_mode_is_eligible

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

  # @return [String] the persisted mode, or 'record_users' when nothing has been written.
  #
  # Overriding the reader, rather than writing a default into the attribute, avoids dirtying
  # every record that never had one. Note that download_reviewer_mode_was then reports
  # 'record_users' as well -- ActiveFedora captures the prior value through this reader -- so
  # only _changed? distinguishes the unset -> 'object_organization' transition, and it is what
  # object_organization_mode_is_eligible and publish_reviewers_updated guard on.
  def download_reviewer_mode
    super.presence || 'record_users'
  end

  # This media's Reviewer Identity (see CONTEXT.md): User ms_ids, or one
  # "org_collection:<id>" token per OrganizationCollection that reviews on its behalf.
  #
  # Organizations are deliberately *not* resolved into Users here. Keeping the token in the
  # index means a change to an organization's managers does not require reindexing every
  # media it reviews. Morphosource::DownloadReviewerResolver performs Reviewer Resolution.
  #
  # Reviewer Eligibility (reviews_object_media_downloads) is never consulted: it is checked
  # once, when the mode changes, so that Grandfathering holds.
  #
  # @param object_organizations [Array, nil] this media's Object Organizations, when the caller
  #   has already loaded them. MediaIndexer walks the same ancestors for its own keys and passes
  #   the result rather than paying for a second walk; every other caller omits it. Consulted
  #   only in object_organization mode, so record_users mode never walks either way.
  # @return [Array<String>] User ms_ids and/or org_collection: tokens
  def download_reviewers(object_organizations = nil)
    if download_reviewer_mode == 'object_organization'
      orgs = object_organizations || organizations
      return orgs.map { |org| org_collection_token(org.id) }.uniq
    end

    record_users = Array(record_download_reviewer_users).reject(&:blank?)
    return record_users.uniq if record_users.present?

    owner_download_reviewers
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
    if (
      self.visibility_changed? &&
      self.visibility == 'open' &&
      self.organization_transfer_on_publish
    )
      TransferToOrganizationJob.perform_later(self.id)
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

  def transfer_media_to_organization
    org = organizations&.first
    case org
    when OrganizationCollection
      transfer_media_to_organization_collection(org)
    when Organization
      raise NotImplementedError, "Org teams are defunct; media organization must be an OrganizationCollection"
    end
  end

  # Org teams are defunct; all organizations now use OrganizationCollection.
  # This method is kept as a tombstone so callers raise loudly rather than silently no-op.
  def transfer_media_to_organizational_team(_org)
    raise NotImplementedError, "Org teams are defunct; use transfer_media_to_organization_collection instead"
  end

  def transfer_media_to_organization_collection(org)
    # check if organization is already the media owner
    return if user_with_ownership == org.id
    # check that organization has a valid data manager
    if org.managers&.first.present?
      # First, is media manager user the same as the new org data manager?
      owner_user = User.find_by(ms_id: user_with_ownership)
      proxy_user = User.find_by(ms_id: on_behalf_of)
      if owner_user.groups.include?("#{org.id}_managers") || proxy_user&.groups&.include?("#{org.id}_managers")
        # don't create transfer, but add organization as media owner and ensure no further transfers are created
        self.owner = org.id
      else
        create_new_organization_transfer_request(org)
      end
      if self.organization_transfer_on_publish
        self.organization_transfer_on_publish = false
      end
      self.save!
    else
      message = "Failed to transfer management of media #{id} to organization #{org&.id}"

      Rails.logger.fatal message
      raise message
    end
  end

  # Org teams are defunct; kept as a tombstone so any remaining legacy ProxyDepositRequests
  # with receiving_user_type == "User" fail loudly instead of silently no-oping.
  def add_to_organization_team
    raise NotImplementedError, "Org teams are defunct; organization transfers must use OrganizationCollection"
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
    # Flag that a transfer request is now pending; persisted by the calling method's save!
    self.pending_org_transfer = true
  end

  # keeping external file methods for now, but these will be deleted once Simon's remote file changes are incorporated.
  def external_file?
    file_sets&.first&.external_file.present?
  end

  def external_file
    file_sets&.first&.original_file&.external_file
  end

  # Attachment methods

  # Custom method to handle CarrierWave uploader
  def agreement_uploader
    @agreement_uploader ||= MediaAgreementAttachmentUploader.new.tap { |u| u.work_id = id }
  end

  # @param file [File, ActionDispatch::Http::UploadedFile] The file to be attached, or nil to delete the file
  def agreement_attachment=(file)
    if file.nil?
      # delete attachment
      return unless self.agreement_attachment_url.present?
      file_name = File.basename(self.agreement_attachment_url)
      agreement_uploader.retrieve_from_store!(file_name)
      if agreement_uploader.file.present? && File.exist?(agreement_uploader.file.path)
        Rails.logger.info "Deleting file: #{agreement_uploader.file.path}"
        agreement_uploader.remove!
      else
        Rails.logger.warn "File not found: #{agreement_uploader.file&.path}"
      end
      self.agreement_attachment_url = nil
      self.save
    else
      # add attachment
      extension = File.extname(file.original_filename).downcase
      if agreement_attachment_formats.include?(extension)
        agreement_uploader.store!(file)
        self.agreement_attachment_url = agreement_uploader.url
        self.save
      else
        raise ArgumentError, "Invalid file format: #{extension}"
      end
    end
  end

  def agreement_attachment
    self.agreement_attachment_url
  end

  def agreement_attachment_formats
    @agreement_attachment_formats ||= Morphosource.attachment_formats
  end

  def copy_organization_agreement_attachment(organization)
    return unless organization.agreement_attachment_url.present?
    file_path = organization.agreement_attachment_full_path
    if File.exist?(file_path)
      file = ActionDispatch::Http::UploadedFile.new(
        filename: File.basename(file_path),
        type: Marcel::MimeType.for(file_path),
        tempfile: File.open(file_path)
      )
      self.agreement_attachment = file
    else
      Rails.logger.error("Unable to copy agreement attachment from organization. File not found: #{file_path}")
    end
  end

  def scene
    Scene.find_by(media_id: self.id)
  end

  private

    def add_id_to_title
      unless self.title && self.id && self.title.first.to_s.start_with?("M#{self.id.to_s}: ")
        self.title.set("M#{self.id.to_s}: #{self.title.first.to_s}")
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

    # Publish object.deleted event when media is destroyed
    def publish_destroyed_event
      event_user = User.find_by_user_key(Hyrax.config.system_user_key) || User.find_by_user_key(depositor)
      return if event_user.nil?

      Hyrax.publisher.publish('object.deleted', object: self, user: event_user)
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

    # The owner stands in for the record's reviewers when it names none of its own. It holds
    # either a User ms_id or an OrganizationCollection id, so an org-owned media routes to that
    # organization rather than nowhere.
    def owner_download_reviewers
      owner_id = Array(user_with_ownership).first
      return [] if owner_id.blank?
      # exists? rather than find_by: find_by reifies the collection from Fedora to answer a
      # boolean, and this runs for every media indexed.
      return [org_collection_token(owner_id)] if OrganizationCollection.exists?(owner_id)

      [owner_id]
    end

    def org_collection_token(organization_id)
      "#{Morphosource::MediaMetadata::ORG_COLLECTION_TOKEN_PREFIX}#{organization_id}"
    end

    # Entering 'object_organization' mode requires every one of the media's Object
    # Organizations to be eligible, not merely one: a media shared between a paying and a
    # non-paying organization must not silently drop the second from review.
    #
    # Checked only on the transition. The walk is expensive — physical_objects traverses
    # ancestors, and PhysicalObjectBehavior#organizations loads each organization from Fedora —
    # and re-checking later would fail an unrelated edit on a record that was valid a moment
    # earlier, contradicting Grandfathering. Reading media_organization_id_ssim from Solr would
    # be cheaper, but a stale index would silently grant eligibility.
    #
    # An empty set passes: at create time the ImagingEvent parent may not be linked yet. The
    # submission path checks the organization it already holds (SubmissionsController).
    def object_organization_mode_is_eligible
      return unless download_reviewer_mode_changed?
      return unless download_reviewer_mode == 'object_organization'

      # try: physical objects may still resolve to the deprecated Organization model, which has
      # no such property and is therefore never eligible.
      ineligible = organizations.reject { |org| org.try(:reviews_object_media_downloads) }
      return if ineligible.empty?

      names = ineligible.map { |org| org.title&.first }.compact
      errors.add(:download_reviewer_mode,
                 "cannot be set to the object organization: #{names.to_sentence} " \
                 "#{ineligible.one? ? 'does' : 'do'} not review download requests for media of their objects")
    end

    # ActiveFedora saves publish no Hyrax events, so the model publishes its own.
    def publish_reviewers_updated
      return if skip_reviewer_event
      return unless download_reviewer_mode_changed? || record_download_reviewer_users_changed?

      Hyrax.publisher.publish('media.reviewers.updated', media_id: id)
    rescue StandardError => e
      Rails.logger.error("Media: failed to publish media.reviewers.updated for #{id}; " \
                         "its cart items' cached reviewers are now stale. #{e.class}: #{e.message}")
      Sentry.capture_exception(e, extra: { media_id: id })
    end
end
