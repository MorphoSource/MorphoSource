require 'rails_helper'

RSpec.describe Morphosource::WorkUploadsHandler do
  let(:user) { create(:user) }
  let(:work) { create(:media, depositor: user.user_key) }
  let(:local_file) { File.open(Rails.root.join('spec/fixtures/images/ms.jpg')) }
  let(:uploaded_file) { Hyrax::UploadedFile.create(user_id: user.id, file: local_file) }

  describe '#attach' do
    it 'calls InheritPermissionsJob so the new FileSet inherits edit access from the work' do
      expect(InheritPermissionsJob).to receive(:perform_later).with(work.id)

      described_class.new(work: work).add(files: [uploaded_file]).attach
    end
  end
end
