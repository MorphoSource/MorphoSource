class User < ApplicationRecord
  # used for creating ms_id
  require 'securerandom'

  has_many :cart_items, primary_key: :ms_id, foreign_key: :user_id

  paginates_per 10

  # assign user a ms_id to use as user_key
  before_create :check_ms_id

  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles

  # Retrieves profile checkbox options
  include Morphosource::UserProfile::CheckboxValues

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
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  MULTI_VALUE_FIELDS = {
    demographics: DEMOGRAPHICS,
    intent: INTENT,
    software: SOFTWARE,
    mesh_file_type: MESH,
    volume_file_type: VOLUME,
    printer_model: PRINTER_MODEL,
    printer_file: PRINTER_FILE
  }

   MULTI_VALUE_FIELDS.each_key do |field|
     serialize field, Array
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
    display_name.blank? ? email : display_name
  end

  def registered?
    groups.include? 'registered'
  end

  # Mailboxer (the notification system) needs the User object to respond to this method
  # in order to send emails
  def mailboxer_email(_object)
    email
  end

  # true if user has download access or an approved cart item
  def has_download_access_or_approval?(media_id)
    (self.can? :download, media_id) || (downloadable_item_work_ids.include? media_id)
  end

  def approved_to_download?(media_id)
    downloadable_item_work_ids.include? media_id
  end

  def items_in_cart
    cart_items.select(&:in_cart?)
  end

  def item_ids_in_cart
    items_in_cart.map(&:id)
  end

  def work_ids_in_cart
    items_in_cart.map(&:work_id)
  end

  # restricted items user has added to cart
  def restricted_items_in_cart
    items_in_cart.select(&:restricted?)
  end

  def restricted_items_in_cart_ids
    restricted_items_in_cart.map(&:id)
  end

  def downloadable_items
    cart_items.select(&:downloadable?)
  end

  def downloadable_ids
    downloadable_items.map(&:id)
  end

  def downloadable_item_work_ids
    downloadable_items.map(&:work_id)
  end

  def downloadable_items_in_cart
    downloadable_items.select(&:in_cart?)
  end

  def downloadable_ids_in_cart
    downloadable_items_in_cart.map(&:id)
  end

  # all a user's current and past requests (items where user is requestor)
  def my_requests
    cart_items.select{ |item| item.date_requested? || item.date_cleared? }
  end

  def my_requests_ids
    my_requests.map(&:id)
  end

  def my_requests_work_ids
    my_requests.map(&:work_id)
  end

  def my_active_requests
    active_statuses = ["Approved","Requested","Cleared"]
    my_requests.select{ |item| active_statuses.include? item.request_status }
  end

  def my_active_requests_work_ids
    my_active_requests.map(&:work_id)
  end

  def my_cleared_requests
    my_requests.select{|item| item.request_status == "Cleared" }
  end

  def my_cleared_requests_work_ids
    my_cleared_requests.map(&:work_id)
  end

  def downloaded_items
    cart_items.select(&:date_downloaded?)
  end

  def downloaded_item_ids
    downloaded_items.map(&:id)
  end

  def downloaded_work_ids
    downloaded_items.map(&:work_id)
  end

  # items requested from user (items where user is data manager)
  def requests
    media = Media.all.select{|m| m.reviewer == self.ms_id}.map(&:id)
    items = CartItem.where(work_id: media)
    items.select{ |i| i.date_requested? || i.date_cleared? }
  end

  # TODO: Remove
  # def requested_items
    # requests
  # end

  def newly_requested_items
    requests.select{ |item| item.request_status == "Requested" }
  end

  def previously_requested_items
    requests - newly_requested_items
  end

  def requested_item_ids
    requests.map(&:id)
  end

  def previously_requested_item_ids
    previously_requested_items.map(&:id)
  end

  def newly_requested_item_ids
    newly_requested_items.map(&:id)
  end

  def requested_items_work_ids
    requests.map(&:work_id)
  end

  def previously_requested_items_work_ids
    previously_requested_items.map(&:work_id)
  end

  def newly_requested_items_work_ids
    newly_requested_items.map(&:work_id)
  end

  def newly_requested_items_user_ids
    newly_requested_items.map(&:user_id)
  end

  def previously_requested_items_user_ids
    previously_requested_items.map(&:user_id)
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
    ids = roles.map{|r| r.name.chomp("_managers") if r.name.include? "managers"}.compact
    Collection.where(id: ids)
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

end
