# Responsible for persisting the ownership transfer requests and the state of each request.
# @see ProxyDepositRequest.enum(:status)
# @see ProxyDepositRequest.work_query_service_class for configuration (defaults to Hyrax::WorkQueryService)
# @see Hyrax::WorkQueryService
class ProxyDepositRequest < ActiveRecord::Base
  include ActionView::Helpers::UrlHelper
  include Morphosource::MessageHelper

  class_attribute :work_query_service_class
  self.work_query_service_class = Hyrax::WorkQueryService

  delegate :deleted_work?, :work, :to_s, to: :work_query_service

  private

    def work_query_service
      @work_query_service ||= work_query_service_class.new(id: work_id)
    end

  public

  belongs_to :receiving_user, polymorphic: true
  belongs_to :sending_user, class_name: 'User'

  # @param [User] user - the person who needs to take action on the ownership transfer request
  # @param [number_of_days] - for pulling either all transfers, or just x number of days
  # @return [Enumerable] a set of requests that the given user can act upon to claim the ownership transfer
  # @note We are iterating through the found objects and querying SOLR each time. Assuming we are rendering this result in a view,
  #       this is reasonable. In the view we will render the #to_s of the associated work. So we may as well preload the SOLR document.
  # Replacing deleted_work? with remove_deleted_transfers to avoid loading Fedora media objects
  def self.incoming_for(user:, number_of_days:)
    ids = user.collections_managed_ids << user.id
    if number_of_days == 'all'
      transfers = where(receiving_user_id: ids).order('created_at desc')
      remove_deleted_transfers(transfers)
    else
      transfers = where(receiving_user_id: ids).where("created_at > ?", number_of_days.to_i.days.ago).order('created_at desc')
      remove_deleted_transfers(transfers)
    end
  end

  def self.remove_deleted_transfers(transfers)
    return transfers if transfers.empty?

    transfer_ids = transfers.map(&:work_id)
    existing_ids = Morphosource::SolrService.new.get_docs(nil, fq:["id:(#{transfer_ids.join(' OR ')})"], fl: ["id"]).map{|doc| doc["id"]}
    missing_ids = transfer_ids - existing_ids
    return transfers if missing_ids.empty?

    missing_requests = ProxyDepositRequest.where(work_id: missing_ids)
    transfers - missing_requests
  end

  # @param [User] user - the person who requested that a work be transfer to someone else
  # @param [number_of_days] - for pulling either all transfers, or just x number of days
  # @return [Enumerable] a set of requests created by the given user
  # @todo Should I skip deleted works as indicated in the .incoming_for method?
  def self.outgoing_for(user:, number_of_days:)
    if number_of_days == 'all'
      where(sending_user: user).order('created_at desc')
    else
      where(sending_user: user).where("created_at > ?", number_of_days.to_i.days.ago).order('created_at desc')
    end
  end

  # attribute work_id exists as result of renaming in db migrations.
  # See upgrade700_generator.rb

  validates :sending_user, :work_id, presence: true
  validate :transfer_to_should_be_a_valid_username
  validate :transfer_to_should_be_a_contributor
  validate :sending_user_should_not_be_receiving_user
  validate :should_not_be_already_part_of_a_transfer
  validate :should_not_cancel_if_organization_transfer

  after_save :send_request_transfer_message

  # @param [String] user_key - The key of the user that will receive the transfer
  # @note The HTML form for creating a ProxyDepositRequest requires this method
  def transfer_to=(user_key)
    self.receiving_user_id = select_receiving_user(user_key).id # user or organization collection
  end

  def receiving_user
    select_receiving_user(receiving_user_id)
  end

  def select_receiving_user(user_key)
    @receiving_user ||= (User.find_by(id: user_key) || OrganizationCollection.find_by(id: user_key))
  end

  # @return [nil, String] nil if we don't have a receiving user, otherwise it returns the receiving_user's user_key
  # @note The HTML form for creating a ProxyDepositRequest requires this method
  # @see User#user_key
  def transfer_to
    receiving_user.try(:user_key)
  end

  def receiving_organization
    receiving_user if receiving_user.is_a?(OrganizationCollection)
  end

  private

    def transfer_to_should_be_a_contributor
      return if receiving_organization

      errors.add(:transfer_to, "must have contributor access") unless receiving_user.contributor?
    end

    def transfer_to_should_be_a_valid_username
      return if receiving_organization

      errors.add(:transfer_to, "must be an existing user") unless receiving_user
    end

    def sending_user_should_not_be_receiving_user
      return if receiving_organization

      errors.add(:transfer_to, 'specify a different user to receive the work') if receiving_user && receiving_user.user_key == sending_user.user_key
    end

    def should_not_be_already_part_of_a_transfer
      transfers = ProxyDepositRequest.where(work_id: work_id, status: PENDING)
      errors.add(:open_transfer, 'must close open transfer on the work before creating a new one') unless transfers.blank? || (transfers.count == 1 && transfers[0].id == id)
    end

    def should_not_cancel_if_organization_transfer
      errors.add(:organization_transfer, 'sending user can not cancel an organization transfer') if ( status == CANCELED && organization_transfer && !@force_update )
    end

  public

  def send_request_transfer_message
    if updated_at == created_at # on initial request creation
      if organization_transfer
        # Message transfer sender and recipient
        send_org_transfer_message_to_receivers
        send_org_transfer_message_to_sender
      else
        # Only message transfer recipient
        send_request_transfer_create_message(receiving_user)
      end
    else
      send_request_transfer_update_message
    end
  end

  private

  def send_org_transfer_message_to_receivers
      # Organizaton collection or legacy organization?
      if receiving_user.is_a? OrganizationCollection
        receiving_user.managers.each { |manager| send_org_transfer_message_to_receiver(manager) }
      else
        send_org_transfer_message_to_receiver(receiving_user)
      end
  end

  def send_org_transfer_message_to_receiver(recipient)
    message = I18n.t("hyrax.transfers.message.org_transfer_receiver", 
      message_content: message_content, organization_content: organization_content, 
      transfer_link: transfers_dashboard_link, user_link: user_link(sending_user)
    ).html_safe
    message += "<p>Comment: #{sender_comment}</p>" if sender_comment.present?
    
    deliver_message(
      email_sender, 
      recipient, 
      message.html_safe, 
      I18n.t("hyrax.transfers.message.org_transfer_receiver_subject")
    )
  end

  def send_org_transfer_message_to_sender
    message = I18n.t("hyrax.transfers.message.org_transfer_sender", 
      message_content: message_content, organization_link: organization_link
    ).html_safe
    
    deliver_message(
      email_sender, 
      sending_user, 
      message.html_safe,
      I18n.t("hyrax.transfers.message.org_transfer_sender_subject")
    )
  end

  def send_request_transfer_create_message(recipient)
    message = I18n.t("hyrax.transfers.message.transfer_create", 
      message_content: message_content, transfer_link: transfers_dashboard_link, 
      user_link: user_link(sending_user)
    ).html_safe
    message += "<p>Comment: #{sender_comment}</p>" if sender_comment.present?
    
    deliver_message(
      email_sender, 
      recipient, 
      message.html_safe, 
      I18n.t("hyrax.transfers.message.transfer_create_subject")
    )
  end

  def send_request_transfer_update_message
    receiver_link = receiving_user.is_a?(OrganizationCollection) ? organization_link : user_link(receiving_user)
    
    message = I18n.t("hyrax.transfers.message.transfer_update_p1", 
      message_content: message_content, status: status, receiver_link: receiver_link
    ).html_safe
    message_p2 = I18n.t("hyrax.transfers.message.transfer_update_p2", receiver_link: receiver_link).html_safe
    message += "<p>#{message_p2}</p>".html_safe

    deliver_message(
      email_sender, 
      sending_user, 
      message.html_safe, 
      I18n.t("hyrax.transfers.message.transfer_update_subject", status: status)
    )
  end

  def message_content
    tag.b link_to(
      "Media #{work.id}: #{work.title.first}",
      Rails.application.routes.url_helpers.media_showcase_url(work, host: host_name)
    )
  end

  def organization_content
    "organization#{receiving_user.is_a?(OrganizationCollection) ? " (#{organization_link})" : ""}"
  end

  def organization_link
    link_to(
      receiving_user.name, 
      Rails.application.routes.url_helpers.organization_url(receiving_user, host: host_name)
    )
  end

  def transfers_dashboard_link
    link_to(
      "Ownership Transfers",
      Hyrax::Engine.routes.url_helpers.transfers_url(host: host_name)
    )
  end

  def user_link(user)
    link_to(
      user.name_or_email,
      Hyrax::Engine.routes.url_helpers.user_url(user, host: host_name)
    )
  end

  public

  ACCEPTED = 'accepted'.freeze
  PENDING = 'pending'.freeze
  CANCELED = 'canceled'.freeze
  REJECTED = 'rejected'.freeze

  enum(
    status: {
      ACCEPTED => ACCEPTED,
      CANCELED => CANCELED,
      PENDING => PENDING,
      REJECTED => REJECTED
    }
  )

  # @param [TrueClass,FalseClass] reset (false)  if true, reset the access controls. This revokes edit access from the depositor
  def transfer!(reset = false)
    if organization_transfer && receiving_user_type == "User"
      work.add_to_organization_team
    end
    ContentDepositorChangeEventJob.perform_now(work, receiving_user_id, reset, sending_user_id)
    fulfill!(status: ACCEPTED)
  end

  # @param [String, nil] comment - A given reason by the rejecting user
  def reject!(comment = nil)
    fulfill!(status: REJECTED, comment: comment)
  end

  def cancel!
    fulfill!(status: CANCELED)
  end

  def force_cancel!
    @force_update = true
    fulfill!(status: CANCELED)
  end

  private
    def fulfill!(status:, comment: nil)
      self.receiver_comment = comment if comment
      self.status = status
      self.fulfillment_date = Time.current
      save!
    end
end
