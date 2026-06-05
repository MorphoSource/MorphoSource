# Generated via
#  `rails generate hyrax:work Device`
require 'rails_helper'

RSpec.describe FileSet do

  describe "metadata attributes" do

    it "includes accessibility" do
      expect(subject.attributes).to include('accessibility')
    end
  end

  describe "instance" do
    subject { FileSet.new({accessibility: ['preview']})}

    it "creates with correct accessibility" do
      expect(subject.accessibility.first).to eq('preview')
    end
  end

  describe 'FileSetSizeInfo integration' do
    let(:file_set) { FactoryBot.create(:file_set) }

    describe 'after_create' do
      it 'creates a FileSetSizeInfo row on save' do
        expect { FactoryBot.create(:file_set) }.to change(FileSetSizeInfo, :count).by(1)
      end

      it 'sets file_set_id on the new row' do
        expect(FileSetSizeInfo.find_by(file_set_id: file_set.id.to_s)).to be_present
      end
    end

    describe 'after_destroy' do
      it 'removes the FileSetSizeInfo row' do
        file_set  # force creation
        expect { file_set.destroy }.to change(FileSetSizeInfo, :count).by(-1)
      end

      it 'the row is gone after destroy' do
        id = file_set.id.to_s
        file_set.destroy
        expect(FileSetSizeInfo.find_by(file_set_id: id)).to be_nil
      end
    end

    describe '#data_allocation_id' do
      it 'returns nil when no data_allocation_id is set' do
        expect(file_set.data_allocation_id).to be_nil
      end

      it 'reads data_allocation_id from FileSetSizeInfo' do
        da = DataAllocation.create!(allocation_type: :user)
        FileSetSizeInfo.find_by(file_set_id: file_set.id.to_s).update!(data_allocation_id: da.id)
        expect(file_set.data_allocation_id).to eq(da.id)
      end
    end

    describe '#update_size_info' do
      it 'updates binary_file_size on the FileSetSizeInfo row' do
        file_set.update_size_info(binary_file_size: 12_345)
        expect(FileSetSizeInfo.find_by(file_set_id: file_set.id.to_s).binary_file_size).to eq(12_345)
      end

      it 'recomputes sum_file_size' do
        file_set.update_size_info(binary_file_size: 10_000, summed_derivatives_file_size: 2_000)
        row = FileSetSizeInfo.find_by(file_set_id: file_set.id.to_s)
        expect(row.sum_file_size).to eq(12_000)
      end
    end
  end
end
