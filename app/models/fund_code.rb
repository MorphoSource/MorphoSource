class FundCode < ApplicationRecord
  belongs_to :user
  has_many :fund_code_memberships, :dependent => :destroy
  has_many :members, :through => :fund_code_memberships, :source => :user
  has_many :fund_code_media_associations
  has_many :charges, class_name: "FundCodeCharge"

  def add_user(user, manager = false)
    return nil if fund_code_memberships.where(user_id: user.id).present?
    fund_code_memberships << FundCodeMembership.new(user: user, manager: manager)
  end

  def delete_user(user)
    fund_code_memberships.where(user_id: user.id).destroy_all
  end

  def make_user_manager(user)
    toggle_user_status(user, true)
  end

  def make_user_standard(user)
    toggle_user_status(user, false)
  end

  def toggle_user_status(user, manager = false)
    fund_code_memberships.where(user_id: user.id).update_all(manager: manager)
  end

  def managers
    members.joins(:fund_code_memberships).where(fund_code_memberships: { manager: true }).uniq
  end

  def standard_members
    members.joins(:fund_code_memberships).where(fund_code_memberships: { manager: false }).uniq
  end

  def media_ids
    fund_code_media_associations.where(active: true).pluck(:media)
  end

  def media
    media_ids.map { |m_id| Media.find(m_id) if Media.exists?(m_id) }.compact
  end
end