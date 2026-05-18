class DataAllocation < ApplicationRecord
  enum allocation_type: { user: 0, fund_code: 1 }

  belongs_to :fund_code, optional: true
  has_many :data_allocation_users, dependent: :destroy
  has_many :users, through: :data_allocation_users

  after_initialize :set_storage_defaults, if: :new_record?

  private

  def set_storage_defaults
    self.storage_total_gb ||= Hyrax.config.default_storage_total_gb
  end
end
