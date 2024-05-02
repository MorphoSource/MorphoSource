class User < ApplicationRecord
  # used for creating ms_id
  require 'securerandom'

  has_many :cart_items, primary_key: :ms_id, foreign_key: :user_id
  has_many :owned_fund_codes, class_name: 'FundCode', foreign_key: :user_id
  has_many :fund_code_memberships
  has_many :fund_codes, :through => :fund_code_memberships
  has_many :proxy_deposit_requests, as: :receiving_user
  has_many :proxy_deposit_requests, as: :sending_user
  has_many :temporary_media_access_links
  has_many :temporary_collection_access_links


  has_secure_token

  paginates_per 10

  # assign user a ms_id to use as user_key
  before_create :check_ms_id
  # increment based on highest current id
  before_create :reset_id_incrementer
  # set display_name to first and last name for individual account
  before_create :set_display_name
  before_update :set_display_name

  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles

  # Retrieves profile checkbox options
  include Morphosource::UserProfile::CheckboxValues

  # Methods related to restricted media requests
  include Morphosource::Users::CartItems

  # Connects this user object to Hyrax behaviors.
  include Hyrax::User
  include Hyrax::UserUsageStats

  if Blacklight::Utils.needs_attr_accessible?
    attr_accessible :email, :password, :password_confirmation
  end
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :confirmable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  MULTI_VALUE_FIELDS = {
    demographics: DEMOGRAPHICS,
    intent: INTENT
  }

   MULTI_VALUE_FIELDS.each_key do |field|
     serialize field, Array
   end

  def self.find_or_create_system_user(user_key)
    User.find_by_user_key(user_key) || User.create!(
      Hydra.config.user_key_field => user_key,
      email: "#{user_key}@system_user",
      password: Devise.friendly_token[0, 20]
    )
  end

  def set_display_name
    if self.profile_type != "Collection or Facility Organization Group"
      if (full_name = "#{self.first_name} #{self.last_name}").strip != ""
        self.display_name = full_name
      end
    end
  end

  # Devise callback for checking if user is active
  def active_for_authentication?
    super && active
  end

  def inactive_message
    active ? super : ms_inactive_message
  end

  def ms_inactive_message
    I18n.t 'user.inactive_message'
  end

  # Devise callback for action after authentication
  def after_database_authentication
    if ms1_user
      self.ms1_user = false
      self.ms1_password_hash = nil
    end
  end

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    ms_id
  end

  def name
    display_name.blank? ? "User #{ms_id.to_s.upcase}" : display_name
  end

  # display email if display name does not exist
  def name_or_email
    display_name.blank? ? email : display_name
  end

  def name_and_email
    display_name.blank? ? email : "#{display_name} (#{email})"
  end

  def registered?
    groups.include? 'registered'
  end

  def organization_collection?
    false
  end

  # Mailboxer (the notification system) needs the User object to respond to this method
  # in order to send emails
  def mailboxer_email(_object)
    email
  end

  def contributor?
    groups.include? 'contributor'
  end

  def make_contributor
    if contributor?
      puts "Can't add - #{display_name} is already a contributor"
    else
      contributor_group.users += [self]
      puts "#{display_name} is now a contributor"
    end
  end

  def remove_contributor
    if !contributor?
      puts "Can't remove - #{display_name} is not a contributor"
    else
      contributor_group.users -= [self]
      puts "#{display_name} contributor status removed"
    end
  end

  def batch_submission_contributor?
    groups.include? 'batch_submission_contributor'
  end

  def make_batch_submission_contributor
    if batch_submission_contributor?
      puts "Can't add - #{display_name} is already a batch submission contributor"
    else
      batch_submission_contributor_group.users += [self]
      puts "#{display_name} is now a batch submission contributor"
    end
  end

  def remove_batch_submission_contributor
    if !batch_submission_contributor?
      puts "Can't remove - #{display_name} is not a batch submission contributor"
    else
      batch_submission_contributor_group.users -= [self]
      puts "#{display_name} batch submission contributor status removed"
    end
  end

  def remote_file_submitter?
    groups.include? 'remote_file_submitter'
  end

  def make_remote_file_submitter
    if remote_file_submitter?
      puts "Can't add - #{display_name} is already a remote file submitter"
    else
      remote_file_submitter_group.users += [self]
      puts "#{display_name} is now a remote file submitter"
    end
  end

  def remove_remote_file_submitter
    if !remote_file_submitter?
      puts "Can't remove - #{display_name} is not a remote file submitter"
    else
      remote_file_submitter_group.users -= [self]
      puts "#{display_name} remote file submitter status removed"
    end
  end

  def can_submit_remote_file?(url, org_id)
    return false unless self.remote_file_submitter? && org_id.present?
    begin
      org = ActiveFedora::Base.find(org_id)
      team = org.class == OrganizationCollection ? org : org&.team
    rescue ActiveFedora::ObjectNotFoundError
      Rails.logger.debug "Error in can_submit_remote_file: organization not found"
      return false
    end
    return false unless team.present?
    if url.nil?
      # if url not available (e.g. determine to show/hide remote file tab),
      # no need to check domain.  Instead, check the permission at the team level and
      # the user's allowed_domains list for the team
      return team.can_submit_remote_files? && team.allowed_remote_source.present? &&
        allowed_domains[team.id].present?
    end
    return false unless allowed_domains[team.id].present?
    white_list = allowed_domains[team.id].split(/\n+|\r+/).reject(&:empty?)
    uri = URI(url)
    return false unless uri.host.present?
    return (white_list.include? uri.host)
  end

  # This returns allowed domains from organizations (Org Collection or legacy org-linked team) that
  # the user has depositor and above access to
  def allowed_domains
    return {} unless self.remote_file_submitter?
    domains = {}
    ids = roles.map{ |r| r.name.gsub(/(_managers|_editors|_depositors)/, "") if r.name.match(/(_managers|_editors|_depositors)/) }.compact
    ids.each do |id|
      if (org = OrganizationCollection.where(id: id)&.first).present?
        if org.can_submit_remote_files? && org.allowed_remote_source.present?
          domains[id] = org.allowed_remote_source
        end
      elsif (c = Collection.where(id: id)&.first).present?
        if c.team? && c.organization.present?
          if c.can_submit_remote_files? && c.allowed_remote_source.present?
            domains[id] = c.allowed_remote_source
          end
        end
      end
    end
    return domains
  end

  def charge_api_user?
    groups.include? 'charge_api'
  end

  def make_charge_api_user
    if charge_api_user?
      puts "Can't add - #{display_name} is already a charge API user"
    else
      charge_api_group.users += [self]
      puts "#{display_name} is now a charge API user"
    end
  end

  def remove_charge_api_user
    if !charge_api_user?
      puts "Can't remove - #{display_name} is not a charge API user"
    else
      charge_api_group.users -= [self]
      puts "#{display_name} charge api user status removed"
    end
  end

  def make_active
    update_attributes(active: true)
  end

  def make_inactive
    update_attributes(active: false)
  end

  # true if user has download access or an approved cart item
  def has_download_access_or_approval?(media_id)
    (self.can? :download, media_id) || (approved_to_download? media_id)
  end

  def approved_to_download?(media_id)
    my_approved_requests_work_ids.include? media_id
  end

  # profile methods
  # populate 'other' field in checkbox lists
  # field name and constant from CheckboxValues

  MULTI_VALUE_FIELDS.each do |field, values|
    define_method('other_'.concat(field.to_s).to_sym) do
      (self.send(field) - values).join
    end
  end

  # finds collections for which user belongs to "_managers" role
  def collections_managed
    ids = collections_managed_ids
    if ids.present?
      Morphosource::SolrService.new
        .get_docs(nil, fq: ["id:(#{ids.join(' OR ').upcase})"], fl: ["id"])
        .map do |solr_doc|
          begin
            Collection.find(solr_doc["id"])
          rescue ActiveFedora::ObjectNotFoundError
            nil
          end
        end
        .compact
    else
      return []
    end
  end

  def collections_managed_ids
    manager_groups.map{ |g| g.chomp("_managers") }
  end

  # finds collection ids for which user belongs to different role
  def collections_with_membership_role_ids
    manager_collection_ids = []
    editor_collection_ids = []
    depositor_collection_ids = []
    downloader_collection_ids = []
    viewer_collection_ids = []
    roles.each do |r|
      if r.name.include? "managers"
        manager_collection_ids << r.name.chomp("_managers")
      elsif r.name.include? "editors"
        editor_collection_ids << r.name.chomp("_editors")
      elsif r.name.include? "downloaders"
        downloader_collection_ids << r.name.chomp("_downloaders")
      elsif r.name.include? "depositors"
        depositor_collection_ids << r.name.chomp("_depositors")
      elsif r.name.include? "viewers"
        viewer_collection_ids << r.name.chomp("_viewers")
      end
    end
    all_memberships_collection_ids = (
            manager_collection_ids +
            editor_collection_ids +
            depositor_collection_ids +
            downloader_collection_ids +
            viewer_collection_ids
            ).compact
    return all_memberships_collection_ids,
            manager_collection_ids.compact,
            editor_collection_ids.compact,
            depositor_collection_ids.compact,
            downloader_collection_ids.compact,
            viewer_collection_ids.compact

  end

  # Fund code methods

  def managed_fund_codes
    fund_codes.joins(:fund_code_memberships).where(fund_code_memberships: { manager: true })
  end

  def standard_member_fund_codes
    fund_codes.joins(:fund_code_memberships).where(fund_code_memberships: { manager: false })
  end

  def background_jobs
    BackgroundJob.where(user: self)
  end

  def batch_submission_jobs
    BackgroundJob.where(user: self).where.not(status:nil)
  end

  def last_batch_submission_job
    batch_submission_jobs.last
  end

  def can_submit_new_batch_submission?
    return true unless batch_submission_jobs.present?
    return last_batch_submission_job.status == "completed" || last_batch_submission_job.status == "failed"
  end

  def manager_groups
    groups.select{|g| g.include?("_managers")}
  end

  def editor_groups
    groups.select{|g| g.include?("_editors")}
  end

  def depositor_groups
    groups.select{|g| g.include?("_depositors")}
  end

  def downloader_groups
    groups.select{|g| g.include?("_downloaders")}
  end

  def viewer_groups
    groups.select{|g| g.include?("_viewers")}
  end

  def collections_managed_solr
    filter = ["(id:(#{self.collections_managed_ids.join(' OR ')}))"]
    Morphosource::SolrService.new.get_docs('', fq: filter)
  end

  def organizations_managed_solr
    collections_managed_solr.select{|doc| doc['has_model_ssim'] == ['OrganizationCollection']}
  end

  private

  # Assigns a random string to be used as the user_key
  def assign_ms_id
    loop do
      self.ms_id = SecureRandom.hex(3)
      break unless User.where(ms_id: ms_id).exists?
    end
  end

  def check_ms_id
    assign_ms_id if ms_id.nil?
  end

  def contributor_group
    Role.find_by(name: 'contributor')
  end

  def batch_submission_contributor_group
    Role.find_by(name: 'batch_submission_contributor')
  end

  def remote_file_submitter_group
    Role.find_by(name: 'remote_file_submitter')
  end

  def charge_api_group
    Role.find_by(name: 'charge_api')
  end

  # Fixes errors from incrementer not advancing to account for console-created users
  def reset_id_incrementer
    ActiveRecord::Base.connection.reset_pk_sequence!("users")
  end

end
