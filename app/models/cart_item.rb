class CartItem < ApplicationRecord

  belongs_to :user, foreign_key: :user_id, primary_key: :ms_id

  belongs_to :approver, class_name: 'User', foreign_key: :approver_id, primary_key: :ms_id

  before_validation :set_approver
  before_create :set_restriction

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

  def editable?
    approved? || expired?
  end

  def unrequested?
    date_requested == nil
  end

  def cleared?
    date_cleared != nil
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

  # download_reviewer or depositor
  def set_approver
    self.approver_id = work.reviewer
  end

  def set_restriction
    self.restricted = work.restricted?
  end
end
