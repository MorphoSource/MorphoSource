# frozen_string_literal: true

require 'rails_helper'
require 'rake'

describe 'morphosource:download_reviewer rake tasks', type: :task do
  let(:export) { Rake::Task['morphosource:download_reviewer:export'] }
  let(:path)   { Rails.root.join('tmp', "download_reviewer_export_#{SecureRandom.hex(4)}.csv").to_s }

  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    export.reenable
  end

  after { FileUtils.rm_f(path) }

  def rows
    CSV.read(path, headers: true)
  end

  describe 'morphosource:download_reviewer:export' do
    let(:reviewer)      { FactoryBot.create(:contributor) }
    let(:organization)  { FactoryBot.create(:organization_collection, download_reviewer: [reviewer.ms_id]) }
    let(:media)         { FactoryBot.create(:media, download_reviewer: [reviewer.ms_id]) }

    context 'with a Media and an OrganizationCollection' do
      before do
        organization
        media
        export.invoke(path)
      end

      it 'writes the expected columns' do
        expect(rows.headers)
          .to eq(%w[id model stored_download_reviewer resolved_reviewers manager_count])
      end

      it 'records the stored value and what Reviewer Resolution returns today for a Media' do
        row = rows.find { |r| r['id'] == media.id }

        expect(row['model']).to eq('Media')
        expect(row['stored_download_reviewer']).to eq(reviewer.ms_id)
        expect(row['resolved_reviewers']).to eq(reviewer.ms_id)
      end

      it 'records the stored value, resolution and Manager count for an OrganizationCollection' do
        row = rows.find { |r| r['id'] == organization.id }

        expect(row['model']).to eq('OrganizationCollection')
        expect(row['stored_download_reviewer']).to eq(reviewer.ms_id)
        expect(row['resolved_reviewers']).to eq(reviewer.ms_id)
        expect(row['manager_count']).to eq('0')
      end
    end

    it 'reports an organization with zero Managers without failing' do
      organization

      expect { export.invoke(path) }.not_to raise_error

      summary = Morphosource::DownloadReviewerExport
                .new(path: path, scope: 'organizations').call
      expect(summary[:zero_manager_organizations].map { |o| o[:id] }).to include(organization.id)
    end

    it 'leaves an existing export in place when a read fails partway' do
      File.write(path, "previous baseline\n")
      allow(CartItem).to receive(:count).and_raise(ActiveRecord::StatementInvalid, 'boom')

      expect { Morphosource::DownloadReviewerExport.new(path: path).call }
        .to raise_error(ActiveRecord::StatementInvalid)

      expect(File.read(path)).to eq("previous baseline\n")
      expect(Dir.glob("#{path}.*.part")).to be_empty
    end

    it 'resolves Media reviewers without loading them from Fedora' do
      media
      expect(Media).not_to receive(:find)

      Morphosource::DownloadReviewerExport.new(path: path, scope: 'media').call

      row = rows.find { |r| r['id'] == media.id }
      expect(row['resolved_reviewers']).to eq(reviewer.ms_id)
    end

    context 'scoped to organizations' do
      before do
        organization
        media
        export.invoke(path, 'organizations')
      end

      it 'skips the Media walk' do
        expect(rows.map { |r| r['model'] }.uniq).to eq(['OrganizationCollection'])
      end
    end
  end
end
