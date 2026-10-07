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

  describe '#current_storage' do
    let(:da) { DataAllocation.create!(allocation_type: :user) }

    it 'returns 0 when no FileSetSizeInfo rows exist' do
      expect(da.current_storage).to eq(0)
    end

    it 'returns the live SUM of sum_file_size across all associated rows' do
      # Use binary_file_size so compute_sum_file_size sets sum_file_size correctly
      FileSetSizeInfo.create!(file_set_id: 'fs-a', data_allocation_id: da.id, binary_file_size: 1_000_000)
      FileSetSizeInfo.create!(file_set_id: 'fs-b', data_allocation_id: da.id, binary_file_size: 2_000_000)
      expect(da.current_storage).to eq(3_000_000)
    end

    it 'reflects changes immediately without caching' do
      row = FileSetSizeInfo.create!(file_set_id: 'fs-c', data_allocation_id: da.id, binary_file_size: 500)
      expect { row.update_column(:sum_file_size, 99_999) }
        .to change { da.current_storage }.from(500).to(99_999)
    end

    it 'only counts rows for this DataAllocation' do
      other_da = DataAllocation.create!(allocation_type: :user)
      FileSetSizeInfo.create!(file_set_id: 'fs-d', data_allocation_id: da.id,       binary_file_size: 1_000)
      FileSetSizeInfo.create!(file_set_id: 'fs-e', data_allocation_id: other_da.id, binary_file_size: 9_000)
      expect(da.current_storage).to eq(1_000)
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
