require 'rails_helper'

RSpec.describe FundCodeMediaAssociation do 
  it { should belong_to(:fund_code) }

  describe "instance" do
    let(:user) { User.create(email: 'user@email.com', password: 'password') }
    let(:fund_code) { FundCode.new(title: 'Test Title', description: 'Test Description', user: user) }

    subject { described_class.new }

    it "is valid with valid attributes" do
      subject.fund_code = fund_code
      subject.media = "123456789"
      subject.active = true
      expect(subject).to be_valid
    end
  end

  describe 'FileSetSizeInfo data_allocation_id sync' do
    let(:user)     { User.create!(email: 'fcma_test@example.com', password: 'password') }
    let(:fc)       { FundCode.create!(title: 'FC', description: 'd', user: user) }
    let(:da)       { fc.data_allocation }
    let(:media_id) { 'test_media_fcma' }
    let!(:row)     { FileSetSizeInfo.create!(file_set_id: 'test_fs_fcma', media_id: media_id) }

    describe 'after_save (active: true)' do
      it 'sets data_allocation_id on FileSetSizeInfo rows for the media' do
        described_class.create!(fund_code: fc, media: media_id, active: true)
        expect(row.reload.data_allocation_id).to eq(da.id)
      end
    end

    describe 'after_save (active: false)' do
      before { described_class.create!(fund_code: fc, media: media_id, active: true) }

      it 'clears data_allocation_id when association is set inactive' do
        assoc = described_class.find_by(media: media_id, active: true)
        assoc.update!(active: false)
        expect(row.reload.data_allocation_id).to be_nil
      end
    end

    describe 'after_destroy' do
      before { described_class.create!(fund_code: fc, media: media_id, active: true) }

      it 'clears data_allocation_id when association is destroyed' do
        described_class.find_by(media: media_id).destroy!
        expect(row.reload.data_allocation_id).to be_nil
      end
    end
  end
end
