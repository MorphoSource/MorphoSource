require 'rails_helper'

RSpec.describe FundCodeMembership do
  it { should belong_to(:user) }
  it { should belong_to(:fund_code) }
end
