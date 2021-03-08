class FundCodeMembership < ApplicationRecord
  belongs_to :fund_code
  belongs_to :user
end
