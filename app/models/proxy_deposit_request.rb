# Responsible for persisting the ownership transfer requests and the state of each request.
# @see ProxyDepositRequest.enum(:status)
# @see ProxyDepositRequest.work_query_service_class for configuration (defaults to Hyrax::WorkQueryService)
# @see Hyrax::WorkQueryService
class ProxyDepositRequest < ActiveRecord::Base
  include ActionView::Helpers::UrlHelper
  include Morphosource::MessageHelper

  class_attribute :work_query_service_class
  self.work_query_service_class = Hyrax::WorkQueryService
  attr_accessor :force_update

  delegate :deleted_work?, :work, :to_s, to: :work_query_service

  private

    def work_query_service
      @work_query_service ||= work_query_service_class.new(id: work_id)
    end

  public

  belongs_to :receiving_user, class_name: 'User'
  belongs_to :sending_user, class_name: 'User'

  # @param [User] user - the person who needs to take action on the ownership transfer request
  # @param [number_of_days] - for pulling either all transfers, or just x number of days
  # @return [Enumerable] a set of requests that the given user can act upon to claim the ownership transfer
  # @note We are iterating through the found objects and querying SOLR each time. Assuming we are rendering this result in a view,
  #       this is reasonable. In the view we will render the #to_s of the associated work. So we may as well preload the SOLR document.
  # Replacing deleted_work? with remove_deleted_transfers to avoid loading Fedora media objects
  def self.incoming_for(user:, number_of_days:)
    if number_of_days == 'all'
      transfers = where(receiving_user: user).order('created_at desc')
      remove_deleted_transfers(transfers)
    else
      transfers = where(receiving_user: user).where("created_at > ?", number_of_days.to_i.days.ago).order('created_at desc')
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
    self.receiving_user = User.find_by_user_key(user_key)
  end

  # @return [nil, String] nil if we don't have a receiving user, otherwise it returns the receiving_user's user_key
  # @note The HTML form for creating a ProxyDepositRequest requires this method
  # @see User#user_key
  def transfer_to
    receiving_user.try(:user_key)
  end

  private

    def transfer_to_should_be_a_contributor
      errors.add(:transfer_to, "must have contributor access") unless receiving_user.contributor?
    end

    def transfer_to_should_be_a_valid_username
      errors.add(:transfer_to, "must be an existing user") unless receiving_user
    end

    def sending_user_should_not_be_receiving_user
      errors.add(:transfer_to, 'specify a different user to receive the work') if receiving_user && receiving_user.user_key == sending_user.user_key
    end

    def should_not_be_already_part_of_a_transfer
      transfers = ProxyDepositRequest.where(work_id: work_id, status: PENDING)
      errors.add(:open_transfer, 'must close open transfer on the work before creating a new one') unless transfers.blank? || (transfers.count == 1 && transfers[0].id == id)
    end

    def should_not_cancel_if_organization_transfer
      errors.add(:organization_transfer, 'sending user can not cancel an organization transfer') if status == CANCELED && organization_transfer && !force_update
    end

  public

  def send_request_transfer_message
    if updated_at == created_at
      send_request_transfer_message_as_part_of_create
      send_org_transfer_message_as_part_of_create if organization_transfer
    else
      send_request_transfer_message_as_part_of_update
    end
  end

  private

    def send_request_transfer_message_as_part_of_create
      transfer_link = "<a href='http://#{host_name}/dashboard/transfers'>Transfers of Ownership</a>"
      message = "#{user_email_link([sending_user])} has requested to transfer the ownership of #{message_content} to you.  Please view, accept or reject this request in your #{transfer_link} dashboard."
      message += "<p>Comment: #{sender_comment}</p>" if sender_comment.present?
      deliver_message(email_sender, receiving_user, message.html_safe, "You have a media transfer request")
    end

    def send_request_transfer_message_as_part_of_update
      message = "Your request to transfer ownership of #{message_content} to #{user_email_link([receiving_user])} has been #{status}."
      message += "<p>Please contact #{user_email_link([receiving_user])} if you have a question related to this request.</p>"
      deliver_message(email_sender, sending_user, message.html_safe, "Media transfer request #{status}")
    end

    def send_org_transfer_message_as_part_of_create
      message = "A request to transfer ownership of #{message_content} to organization data manager #{user_email_link([receiving_user])} has been generated. The organization data manager will decide to accept or reject this request. For more details, see our <a href='https://wiki.duke.edu/display/MD/Organization+Ownership+Transfers' target='_blank'>documentation</a>."
      deliver_message(email_sender, sending_user, message.html_safe, "Organization media transfer request generated")
    end

    def message_content
      "<b><a href='http://#{host_name}/media/#{work.id}'>Media #{work.id}: #{work.title.first}</a></b>"
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
    work.add_to_organization_team if organization_transfer
    ContentDepositorChangeEventJob.perform_later(work, receiving_user, reset, sending_user)
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
