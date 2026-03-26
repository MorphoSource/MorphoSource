class FundCode < ApplicationRecord
  belongs_to :user
  has_many :fund_code_memberships, :dependent => :destroy
  has_many :members, :through => :fund_code_memberships, :source => :user
  has_many :fund_code_media_associations
  has_many :charges, class_name: "FundCodeCharge"
  has_many :data_allocations

  mount_uploaders :attachments, FundCodeAttachmentUploader

  before_save :set_total_and_remaining, :set_storage_remaining
  after_create  :create_data_allocation_if_needed
  after_update  :sync_data_allocation_storage_total

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

  def create_data_allocation_if_needed
    return if data_allocations.exists?
    data_allocations.create!(
      allocation_type: :fund_code,
      storage_total_gb: storage_total_gb
    )
  end

  def sync_data_allocation_storage_total
    return unless saved_change_to_storage_total_gb?
    data_allocations.update_all(storage_total_gb: storage_total_gb)
  end

  def set_total_and_remaining
    if total.present? 
      self.total = total.to_d.round(2)
      if !remaining.present?
        self.remaining = total.to_d.round(2)
      end
    end
  end

  def set_storage_remaining
    if storage_total_gb.present? && !storage_remaining_gb.present?
      self.storage_remaining_gb = storage_total_gb.to_d
    end
  end
end