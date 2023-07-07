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
        return SolrDocument.find(work_id)
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

  def any_other_item_approved?
    CartItem.where(work_id: work.id, user: user)
      .where.not(date_approved: nil)
      .where.not(date_expired: nil)
      .where("date_expired >= ?", Date.today)
      .present?
  end

  def downloadable?
    begin
      case
        when work.open_download? then true # if work is published open download
        when reviewer.include?(user) then true # if user is download reviewer
        when user.ms_id == work.user_with_ownership&.first then true # if user owns media
        when approved? then true # if this cart item has been approved to download
        when user.can?(:download, work) then true # if the user has download permissions on media
        when any_other_item_approved? then true # if user has another approved unexpired cart item for this media
        else false
      end
    rescue
      return false
    end
  end

  def has_file_uploaded?
    return work.file_sets.present?
  end

  def user_is_reviewer_or_has_ownership?
    reviewer.include?(user) || user_id == work.user_with_ownership.first
  end

  def reviewer
    User.where(ms_id: work.reviewer)
  end

  def reviewer_names
    reviewer.map { |u| u.name_or_email }.join(', ')
  end

  def reviewer_affiliations
    reviewer.map { |u| u.affiliation }.compact.reject { |a| a.empty? }.join(', ')
  end

end
