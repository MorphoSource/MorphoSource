class CartItem < ApplicationRecord
  belongs_to :media_cart
  paginates_per 10

  before_create :set_approver

  def requester
    media_cart.user
  end

  def requester_email
    requester.email
  end

  def requester_affiliation
    requester.affiliation
  end

  def unrestricted?
    !restricted?
  end

  def active_request?
    return false if unrestricted?
    statuses = ["Approved","Requested","Cleared"]
    statuses.include?(self.request_status)
  end

  def inactive_request?
    return false if unrestricted?
    statuses = ["Canceled","Denied","Expired"]
    statuses.include?(request_status)
  end

  def request_status
    if date_canceled?
      "Canceled"
    elsif date_denied?
      "Denied"
    elsif expired?
      "Expired"
    elsif date_approved?
      "Approved"
    elsif date_cleared?
      "Cleared"
    elsif date_requested?
      "Requested"
    elsif restricted?
      "Not Requested"
    elsif downloadable?
      "Downloadable"
    end
  end

  def downloadable?
    unrestricted? || request_status == 'Approved'
  end

  def approving_user
    User.find_by email: approver
  end

  def work
    Media.find(work_id)
  end

  def expired?
    return false unless date_expired
    date_expired.to_date < Date.today
  end

  def approved?
    request_status == 'Approved'
  end

  # for now, approver = depositor
  def set_approver
    self.approver = work.depositor
  end
end
