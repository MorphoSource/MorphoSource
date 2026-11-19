# frozen_string_literal: true

module Morphosource
  # Download reviewer state for the Media edit page. Reads the stored record, so a refused
  # save renders what is saved rather than what was submitted.
  class MediaReviewerBlock
    # @return [Array] distinct Object Organizations that do not accept new media for download review
    attr_reader :blocked_organizations
    # @return [Array] distinct Object Organizations of the stored record
    attr_reader :object_organizations
    # @return [Array<String>] live reviewer ms_ids; the batch User when nothing else resolves
    attr_reader :reviewer_ms_ids
    # @return [Symbol] :object_organizations, :record_users, :owner_user, :owner_organization or :staff
    attr_reader :source

    # @param media [Media] the form's model, which holds submitted values after a refused save
    def initialize(media)
      @form_media = media
      @media = media.persisted? && media.changed? ? Media.find(media.id) : media
      @object_organizations = @media.organizations.uniq(&:id)
      @blocked_organizations = @media.ineligible_object_organizations(@object_organizations)
      @route_source, @identities = @media.download_reviewer_route(@object_organizations)
      resolution = DownloadReviewerResolver.new.resolve(@identities)
      @reviewer_ms_ids = resolution.ms_ids
      @source = resolution.fallback ? :staff : @route_source
    end

    # @return [Boolean] whether a save in object_organization mode would pass Reviewer Eligibility
    def can_enter_organization_mode?
      object_organizations.any? && blocked_organizations.empty?
    end

    # @return [Boolean]
    def organization_radio_disabled?
      !can_enter_organization_mode? && !stored_organization_mode?
    end

    # @return [Boolean] whether the stored record keeps object_organization mode it could not enter today
    def grandfathered?
      stored_organization_mode? && !can_enter_organization_mode?
    end

    # @return [String] the mode to check: the form's, unless that would check a disabled radio
    def checked_mode
      mode = @form_media.download_reviewer_mode
      mode == 'object_organization' && organization_radio_disabled? ? 'record_users' : mode
    end

    # @return [Array<String>] titles of the organizations the live source names
    def source_organization_titles
      case @route_source
      when :object_organizations then organization_titles(object_organizations)
      when :owner_organization then [owner_organization_title].compact
      else []
      end
    end

    # @return [Symbol] the via line to show; an Owner Organization with no title reads as the owner
    def via_source
      source == :owner_organization && source_organization_titles.empty? ? :owner_user : source
    end

    # @return [Array<String>]
    def object_organization_titles
      organization_titles(object_organizations)
    end

    # @return [Array<String>]
    def blocked_organization_titles
      organization_titles(blocked_organizations)
    end

    # @return [Boolean] whether the record owner is an OrganizationCollection
    def owner_organization?
      owner_organization_title.present?
    end

    # @return [String, nil] the owner's display name, or nil when the owner cannot be resolved
    def owner_label
      return owner_organization_title if owner_organization?

      owner_user&.name_or_email
    end

    private

    def stored_organization_mode?
      @media.download_reviewer_mode == 'object_organization'
    end

    def organization_titles(organizations)
      organizations.map { |org| Array(org.try(:title)).first }.compact
    end

    def owner_id
      return @owner_id if defined?(@owner_id)

      @owner_id = if %i[owner_user owner_organization].include?(@route_source)
                    @identities.first&.delete_prefix(Morphosource::MediaMetadata::ORG_COLLECTION_TOKEN_PREFIX)
                  else
                    Array(@media.user_with_ownership).first.presence
                  end
    end

    def owner_user
      return @owner_user if defined?(@owner_user)

      @owner_user = owner_id && @route_source != :owner_organization ? User.find_by(ms_id: owner_id) : nil
    end

    def owner_organization_title
      return @owner_organization_title if defined?(@owner_organization_title)

      @owner_organization_title = if owner_id && owner_user.nil? && @route_source != :owner_user
                                    solr_organization_title(owner_id)
                                  end
    end

    def solr_organization_title(id)
      document = ActiveFedora::SolrService.query('has_model_ssim:OrganizationCollection',
                                                 fq: ["{!terms f=id}#{id}"], fl: 'id,title_tesim', rows: 1).first
      Array(document&.fetch('title_tesim', nil)).first
    end
  end
end
