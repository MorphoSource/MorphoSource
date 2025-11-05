require 'rails_helper'
RSpec.describe VisibilityCopyJob do

  let(:open_visibility)     { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  let(:private_visibility)  { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
  let(:open_download)       { ['open'] }
  let(:private_download)    { ['private'] }
  let(:restricted_download) { ['restricted_download'] }

  let(:open_work)           { Media.create(title: ['open work'], visibility: open_visibility, fileset_accessibility: open_download) }
  let(:private_work)        { Media.create(title: ['private work'], visibility: private_visibility, fileset_accessibility: private_download) }
  let(:restricted_work)     { Media.create(title: ['restricted work'], visibility: open_visibility, fileset_accessibility: restricted_download) }

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe 'perform' do

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

      context 'work was previously open download' do
        let!(:file_set) { FileSet.create(title: ['file set'], visibility: open_visibility, accessibility: open_download) }

        context 'work has been updated to private' do
          let!(:work) { private_work }

          it 'copies visibility to file sets' do
            subject.perform(work.id)
            file_set.reload
            expect(file_set.visibility).to eq private_visibility
            expect(file_set.accessibility).to eq private_download
          end
        end

        context 'work has been updated to restricted download' do
          let!(:work) { restricted_work }

          it 'copies visibility to file sets' do
            subject.perform(work.id)
            file_set.reload
            expect(file_set.visibility).to eq open_visibility
            expect(file_set.accessibility).to eq restricted_download
          end
        end

        context 'work publication status has not been updated' do
          let!(:work) { open_work }

          it 'copies visibility to file sets' do
            subject.perform(work.id)
            file_set.reload
            expect(file_set.visibility).to eq open_visibility
            expect(file_set.accessibility).to eq open_download
          end
        end
      end

      context 'work was previously private download' do
        let!(:file_set) { FileSet.create(title: ['file set'], visibility: private_visibility, accessibility: private_download) }

        context 'work has been updated to open' do
          let!(:work) { open_work }

          it 'copies visibility to file sets' do
            subject.perform(work.id)
            file_set.reload
            expect(file_set.visibility).to eq open_visibility
            expect(file_set.accessibility).to eq open_download
          end
        end

        context 'work has been updated to restricted download' do
          let!(:work) { restricted_work }

          it 'copies visibility to file sets' do
            subject.perform(work.id)
            file_set.reload
            expect(file_set.visibility).to eq open_visibility
            expect(file_set.accessibility).to eq restricted_download
          end
        end

        context 'work publication status has not been updated' do
          let!(:work) { private_work }

          it 'copies visibility to file sets' do
            subject.perform(work.id)
            file_set.reload
            expect(file_set.visibility).to eq private_visibility
            expect(file_set.accessibility).to eq private_download
          end
        end
      end

      context 'work was previously restricted download' do
        let!(:file_set) { FileSet.create(title: ['file set'], visibility: open_visibility, accessibility: restricted_download) }

        context 'work has been updated to open' do
          let!(:work) { open_work }

          it 'copies visibility to file sets' do
            subject.perform(work.id)
            file_set.reload
            expect(file_set.visibility).to eq open_visibility
            expect(file_set.accessibility).to eq open_download
          end
        end

        context 'work has been updated to private download' do
          let!(:work) { private_work }

          it 'copies visibility to file sets' do
            subject.perform(work.id)
            file_set.reload
            expect(file_set.visibility).to eq private_visibility
            expect(file_set.accessibility).to eq private_download
          end
        end

        context 'work publication status has not been updated' do
          let!(:work) { restricted_work }

          it 'copies visibility to file sets' do
            subject.perform(work.id)
            file_set.reload
            expect(file_set.visibility).to eq open_visibility
            expect(file_set.accessibility).to eq restricted_download
          end
        end
      end
    end
  end
end
