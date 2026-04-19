require 'rails_helper'

RSpec.describe DataAllocation do
  it { should belong_to(:fund_code) }
  it { should have_many(:data_allocation_users) }
  it { should have_many(:users).through(:data_allocation_users) }

  describe "allocation_type enum" do
    it "defines user and fund_code values" do
      expect(DataAllocation.allocation_types).to eq({ "user" => 0, "fund_code" => 1 })
    end
  end

  describe "storage defaults" do
    it "defaults storage_total_gb to Hyrax.config.default_storage_total_gb on new record" do
      da = DataAllocation.new(allocation_type: :user)
      expect(da.storage_total_gb).to eq(Hyrax.config.default_storage_total_gb)
    end

    it "defaults storage_current_gb to 0" do
      da = DataAllocation.new(allocation_type: :user)
      expect(da.storage_current_gb).to eq(0)
    end

    it "does not override an explicitly set storage_total_gb" do
      da = DataAllocation.new(allocation_type: :user, storage_total_gb: 50)
      expect(da.storage_total_gb).to eq(50)
    end
  end

end
