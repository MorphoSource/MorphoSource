class DataAllocationUser < ApplicationRecord
  belongs_to :data_allocation
  belongs_to :user
end
