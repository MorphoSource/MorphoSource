# Can be removed after the Morphosource download reviewer migration is complete and the rake task is no longer needed.
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

  describe 'morphosource:download_reviewer:verify_organizations' do
    let(:reviewer) { FactoryBot.create(:contributor) }
    let(:manager)  { FactoryBot.create(:contributor) }

    let!(:organization) { FactoryBot.create(:organization_collection) }

    subject(:verification) { Morphosource::OrganizationReviewerVerification.new }

    def persist_mode(value)
      organization.managers_are_download_reviewers_will_change!
      organization.managers_are_download_reviewers = value
      organization.save!
    end

    context 'manager mode, no stored reviewers' do
      before do
        organization.managers << manager
        organization.managers_group.save!
        persist_mode(true)
      end

      it 'reports zero diffs' do
        summary = verification.call

        expect(summary[:backfill_diffs]).to be_empty
        expect(summary[:resolution_diffs]).to be_empty
        expect(verification).to be_verified
      end
    end

    context 'manager mode the migration never reached' do
      before do
        organization.managers << manager
        organization.managers_group.save!
      end

      it 'reports the missing flag, which the resolution comparison cannot see' do
        summary = verification.call

        expect(summary[:resolution_diffs]).to be_empty
        expect(summary[:backfill_diffs].first)
          .to include(id: organization.id, expected_mode: true, actual_mode: nil)
        expect(verification).not_to be_verified
      end
    end

    context 'custom mode matching the stored reviewers' do
      before do
        organization.download_reviewer = [reviewer.ms_id]
        organization.managers_are_download_reviewers = false
        organization.custom_download_reviewer_users = [reviewer.ms_id]
        organization.save!
      end

      it 'reports zero diffs' do
        summary = verification.call

        expect(summary[:backfill_diffs]).to be_empty
        expect(summary[:resolution_diffs]).to be_empty
      end
    end

    context 'a stored reviewer that resolves to no User' do
      before do
        organization.download_reviewer = ['org_collection:000200362']
        organization.save!
        organization.managers << manager
        organization.managers_group.save!
        persist_mode(true)
      end

      it 'reports zero diffs' do
        summary = verification.call

        expect(summary[:backfill_diffs]).to be_empty
        expect(verification).to be_verified
      end
    end

    context 'manager mode carrying a stale custom list' do
      before do
        organization.custom_download_reviewer_users = ['left-behind']
        organization.save!
        organization.managers << manager
        organization.managers_group.save!
        persist_mode(true)
      end

      it 'reports the field diff that the resolution comparison misses' do
        summary = verification.call

        expect(summary[:resolution_diffs]).to be_empty
        expect(summary[:backfill_diffs].first)
          .to include(id: organization.id, expected_mode: true, actual_mode: true,
                      expected_users: [], actual_users: ['left-behind'])
        expect(verification).not_to be_verified
      end
    end

    context 'custom mode whose list is missing a stored reviewer' do
      before do
        organization.download_reviewer = [reviewer.ms_id]
        organization.managers_are_download_reviewers = false
        organization.custom_download_reviewer_users = []
        organization.save!
      end

      it 'reports the missing user' do
        summary = verification.call

        expect(summary[:backfill_diffs].first)
          .to include(expected_users: [reviewer.ms_id], actual_users: [])
        expect(verification).not_to be_verified
      end
    end

    context 'a stored reviewer the mode fields do not reflect' do
      before do
        organization.download_reviewer = [reviewer.ms_id]
        organization.save!
        organization.managers << manager
        organization.managers_group.save!
      end

      it 'reports the organization and fails verification' do
        summary = verification.call

        expect(verification).not_to be_verified
        expect(summary[:resolution_diffs].first)
          .to include(id: organization.id, expected: [reviewer.ms_id], actual: [manager.ms_id])
        expect(summary[:backfill_diffs].first)
          .to include(expected_mode: false, actual_mode: nil, expected_users: [reviewer.ms_id])
      end
    end

    it 'reports an id that is in Solr but gone from Fedora' do
      allow(OrganizationCollection).to receive(:find)
        .with(organization.id).and_raise(ActiveFedora::ObjectNotFoundError)

      summary = verification.call

      expect(summary[:unloadable]).to eq([organization.id])
      expect(verification).not_to be_verified
    end

    it 'writes nothing' do
      organization.download_reviewer = [reviewer.ms_id]
      organization.save!

      expect { verification.call }
        .not_to change { organization.reload.managers_are_download_reviewers }
    end
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
