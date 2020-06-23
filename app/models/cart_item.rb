class CartItem < ApplicationRecord

  belongs_to :user, foreign_key: :user_id, primary_key: :ms_id

  def active_request?
    statuses = ["Approved","Requested","Cleared"]
    statuses.include?(request_status)
  end

  def inactive_request?
    statuses = ["Canceled","Denied","Expired"]
    statuses.include?(request_status)
  end

  def request_status
    if downloadable?
      if date_approved?
        "Approved"
      else
        "Downloadable"
      end
    else
      if date_canceled?
        "Canceled"
      elsif date_denied?
        "Denied"
      elsif expired?
        "Expired"
      elsif date_cleared?
        "Cleared"
      elsif date_requested?
        "Requested"
      else
        "Not Requested"
      end
    end
  end

  def restricted?
    !downloadable?
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
    date_approved? && !expired?
  end

  def downloadable?
    case
      when work.open? then true
      when user.can?(:download, work) then true
      when user.ms_id == work.download_reviewer.first then true
      when user.ms_id == work.user_with_ownership then true
      when approved? then true
      else false
    end
  end

  def user_is_reviewer_or_has_ownership?
    user_id == work.reviewer || user_id == work.user_with_ownership
  end

  def reviewer
    User.find_by(ms_id: work.reviewer)
  end
end
