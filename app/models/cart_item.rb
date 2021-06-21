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
    if date_canceled?
      "Canceled"
    elsif date_denied?
      "Denied"
    elsif expired?
      "Expired"
    elsif date_cleared?
      "Cleared"
    elsif date_approved?
      "Approved"
    elsif date_requested?
      "Requested"
    else
      "Not Requested"
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
    @work ||= begin
      begin
        return Media.find(work_id)
      rescue
        return nil
      end
    end
  end

  def user
    @user ||= User.find_by(ms_id: user_id)
  end

  def expired?
    return false unless date_expired
    date_expired.to_date < Date.today
  end

  def approved?
    date_approved? && !expired?
  end

  def downloadable?
    return false unless work.present?
    case
      when work.open? then true
      when user.ms_id == work.download_reviewer.first then true
      when user.ms_id == work.user_with_ownership then true
      when approved? then true
      when user.can?(:download, work) then true
      else false
    end
  end

  def has_file_uploaded?
    return work.file_sets.present?
  end

  def user_is_reviewer_or_has_ownership?
    work.reviewer.include?(user_id) || user_id == work.user_with_ownership
  end

  def reviewer
    User.where(ms_id: work.reviewer)
  end
end
