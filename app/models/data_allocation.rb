class DataAllocation < ApplicationRecord
  enum allocation_type: { user: 0, fund_code: 1 }

  belongs_to :fund_code, optional: true
  has_many :data_allocation_users, dependent: :destroy
  has_many :users, through: :data_allocation_users

  after_initialize :set_storage_defaults, if: :new_record?

  # Live SUM of sum_file_size across all FileSetSizeInfo rows for this allocation.
  # Not cached — always reflects current state.
  def current_storage
    FileSetSizeInfo.where(data_allocation_id: id).sum(:sum_file_size)
  end

  private

  def set_storage_defaults
    self.storage_total_gb ||= Hyrax.config.default_storage_total_gb
  end
end
