class User < ApplicationRecord
  # used for creating ms_id
  require 'securerandom'

  has_many :cart_items, primary_key: :ms_id, foreign_key: :user_id

  has_many :requests, class_name: 'CartItem', primary_key: :ms_id, foreign_key: :approver_id

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

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    ms_id
  end

  def name
    display_name.blank? ? email : display_name
  end

  # Mailboxer (the notification system) needs the User object to respond to this method
  # in order to send emails
  def mailboxer_email(_object)
    email
  end

  def items_in_cart
    cart_items.select{ |i| i.in_cart == true }
  end

  def item_ids_in_cart
    items_in_cart.map{ |i| i.id }
  end

  def work_ids_in_cart
    items_in_cart.map{ |i| i.work_id }
  end

  # restricted items user has added to cart
  def restricted_items_in_cart
    items_in_cart.select{ |item| item.restricted? }
  end

  def restricted_items_in_cart_ids
    restricted_items_in_cart.map{ |item| item.id }
  end

  def downloadable_items
    cart_items.select{ |item| item.downloadable? }
  end

  def downloadable_ids
    downloadable_items.map{ |item| item.id }
  end

  def downloadable_item_work_ids
    downloadable_items.map{ |item| item.work_id }
  end

  def downloadable_items_in_cart
    items_in_cart.select{ |item| item.downloadable? }
  end

  def downloadable_ids_in_cart
    downloadable_items_in_cart.map{ |item| item.id }
  end

  # all a user's current and past requests (items where user is requestor)
  def my_requests
    cart_items.select{ |item| (item.date_requested.present? || item.date_cleared.present?) }
  end

  def my_requests_ids
    my_requests.map{ |item| item.id }
  end

  def my_requests_work_ids
    my_requests.map{ |item| item.work_id }
  end

  def my_active_requests
    active_statuses = ["Approved","Requested","Cleared"]
    my_requests.select{ |item| active_statuses.include?(item.request_status) }
  end

  def my_active_requests_work_ids
    my_active_requests.map{ |item| item.work_id }
  end

  def my_cleared_requests
    my_requests.select{|item| item.request_status == "Cleared" }
  end

  def my_cleared_requests_work_ids
    my_cleared_requests.map{|item| item.work_id }
  end

  def downloaded_items
    cart_items.select{ |i| i.date_downloaded.present? }
  end

  def downloaded_item_ids
    downloaded_items.map{ |i| i.id }
  end

  def downloaded_work_ids
    downloaded_items.map{ |i| i.work_id }
  end

  # items requested from user (items where user is data manager)

  def requested_items
    r = requests.select{ |item| item.restricted? }
    r.select{|item| (!item.date_requested.nil? || !item.date_cleared.nil?)}
  end

  def newly_requested_items
    requested_items.select{ |item| item.request_status == "Requested" }
  end

  def previously_requested_items
    requested_items - newly_requested_items
  end

  def requested_item_ids
    requested_items.map{|item| item.id}
  end

  def previously_requested_item_ids
    previously_requested_items.map{|item| item.id}
  end

  def newly_requested_item_ids
    newly_requested_items.map{|item| item.id}
  end

  def requested_items_work_ids
    requested_items.map{ |item| item.work_id }
  end

  def previously_requested_items_work_ids
    previously_requested_items.map{ |item| item.work_id }
  end

  def newly_requested_items_work_ids
    newly_requested_items.map{ |item| item.work_id }
  end

  def newly_requested_items_user_ids
    newly_requested_items.map{ |item| item.user_id }
  end

  def previously_requested_items_user_ids
    previously_requested_items.map{ |item| item.user_id }
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
