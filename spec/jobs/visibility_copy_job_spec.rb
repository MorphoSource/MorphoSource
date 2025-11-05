require 'rails_helper'
RSpec.describe VisibilityCopyJob do

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe 'perform' do
    let!(:work)         { Media.create(title: ['media']) }
    let!(:file_set)     { FileSet.create(title: ['file set']) }

    context 'work id does not exist' do
      let(:id) { 'nonexistent_work_id' }
      it 'logs and returns' do
        expect(Rails.logger).to receive(:info).with("[VisibilityCopyJob] Work #{id} does not exist, skipping..")
        expect(subject.perform(id)).to be_nil
      end
    end

    context 'work id exists' do
      before do
        work.ordered_members << file_set
        work.save!
      end
    end
  end
end
