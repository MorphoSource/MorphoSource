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

  def row_for(record)
    rows.find { |r| r['id'] == record.id.to_s }
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
        expect(rows.headers).to eq(
          %w[id model media_id stored_download_reviewer resolved_reviewers owner
             manager_count manager_ms_ids fileset_accessibility request_status]
        )
      end

      it 'records the stored value and what Reviewer Resolution returns today for a Media' do
        row = row_for(media)

        expect(row['model']).to eq('Media')
        expect(row['stored_download_reviewer']).to eq(reviewer.ms_id)
        expect(row['resolved_reviewers']).to eq(reviewer.ms_id)
      end

      it 'records the stored value, resolution and Manager count for an OrganizationCollection' do
        row = row_for(organization)

        expect(row['model']).to eq('OrganizationCollection')
        expect(row['stored_download_reviewer']).to eq(reviewer.ms_id)
        expect(row['resolved_reviewers']).to eq(reviewer.ms_id)
        expect(row['manager_count']).to eq('0')
      end
    end

    describe 'the resolution inputs' do
      let(:owner)   { FactoryBot.create(:contributor) }
      let(:manager) { FactoryBot.create(:contributor) }

      it 'records the owner a Media with no stored reviewer falls back to' do
        owned = FactoryBot.create(:restricted_media, owner: owner.ms_id)

        Morphosource::DownloadReviewerExport.new(path: path, scope: 'media').call
        row = row_for(owned)

        expect(row['stored_download_reviewer']).to be_blank
        expect(row['owner']).to eq(owner.ms_id)
        expect(row['resolved_reviewers']).to eq(owner.ms_id)
        expect(row['fileset_accessibility']).to eq('restricted_download')
      end

      it 'resolves an organization-owned Media to the organization Managers' do
        organization.download_reviewer = []
        organization.managers << manager
        organization.managers_group.save!
        organization.save!
        owned = FactoryBot.create(:media, owner: organization.id)

        Morphosource::DownloadReviewerExport.new(path: path, scope: 'media').call
        row = row_for(owned)

        expect(row['owner']).to eq(organization.id)
        expect(row['resolved_reviewers']).to eq(manager.ms_id)
      end

      it 'resolves a Media whose stored reviewer names an OrganizationCollection' do
        organization.download_reviewer = []
        organization.managers << manager
        organization.managers_group.save!
        organization.save!
        org_reviewed = FactoryBot.create(:media, download_reviewer: [organization.id], owner: owner.ms_id)

        Morphosource::DownloadReviewerExport.new(path: path, scope: 'media').call
        row = row_for(org_reviewed)

        expect(row['stored_download_reviewer']).to eq(organization.id)
        expect(row['owner']).to eq(owner.ms_id)
        expect(row['resolved_reviewers']).to eq(manager.ms_id)
      end

      it 'records Manager ms_ids even when a stored reviewer hides them from resolution' do
        organization.managers << manager
        organization.managers_group.save!
        organization.save!

        Morphosource::DownloadReviewerExport.new(path: path, scope: 'organizations').call
        row = row_for(organization)

        expect(row['resolved_reviewers']).to eq(reviewer.ms_id)
        expect(row['manager_ms_ids']).to eq(manager.ms_id)
        expect(row['manager_count']).to eq('1')
      end
    end

    describe 'the deprecated Organization work' do
      it 'exports its stored value so ticket 10 can scope the strip by this file' do
        deprecated = FactoryBot.create(:organization, download_reviewer: [reviewer.ms_id])

        summary = Morphosource::DownloadReviewerExport.new(path: path, scope: 'organizations').call
        row = row_for(deprecated)

        expect(row['model']).to eq('Organization')
        expect(row['stored_download_reviewer']).to eq(reviewer.ms_id)
        expect(summary[:deprecated_organizations_with_stored_reviewer]).to eq(1)
      end

      it 'records a zero count when there are none, rather than assuming it' do
        summary = Morphosource::DownloadReviewerExport.new(path: path, scope: 'organizations').call

        expect(summary[:deprecated_organizations]).to eq(0)
        expect(summary.fetch(:deprecated_organizations_with_stored_reviewer)).to eq(0)
      end
    end

    describe 'cart items' do
      let(:requestor) { FactoryBot.create(:contributor) }

      def cart_item(**attributes)
        CartItem.create!(user_id: requestor.ms_id, work_id: media.id,
                         reviewers: [reviewer.ms_id], **attributes)
      end

      it 'records the stored reviewers snapshot and the request status' do
        pending_item = cart_item(date_requested: Date.yesterday)

        summary = Morphosource::DownloadReviewerExport.new(path: path, scope: 'cart_items').call
        row = row_for(pending_item)

        expect(row['model']).to eq('CartItem')
        expect(row['media_id']).to eq(media.id)
        expect(row['stored_download_reviewer']).to eq(reviewer.ms_id)
        expect(row['request_status']).to eq('Requested')
        expect(summary[:cart_items]).to eq(1)
        expect(summary[:cart_items_with_reviewers]).to eq(1)
      end

      # Pins the SQL predicate against CartItem#request_status: whatever the model calls
      # 'Requested' is exactly what the export writes, for every status the model can return.
      it 'exports every Requested item and nothing in any other status' do
        requested = [
          cart_item(date_requested: Date.yesterday),
          cart_item(date_requested: Date.yesterday, date_expired: Date.tomorrow)
        ]
        others = [
          cart_item(in_cart: true),
          cart_item(date_requested: 2.days.ago, date_canceled: Date.yesterday),
          cart_item(date_requested: 2.days.ago, date_denied: Date.yesterday),
          cart_item(date_requested: 2.days.ago, date_cleared: Date.yesterday),
          cart_item(date_requested: 2.days.ago, date_approved: Date.yesterday),
          cart_item(date_requested: 3.days.ago, date_expired: 2.days.ago)
        ]

        expect(requested.map(&:request_status).uniq).to eq(['Requested'])
        expect(others.map(&:request_status))
          .to eq(%w[Not\ Requested Canceled Denied Cleared Approved Expired])

        summary = Morphosource::DownloadReviewerExport.new(path: path, scope: 'cart_items').call

        expect(rows.map { |r| r['id'] }).to match_array(requested.map { |i| i.id.to_s })
        expect(summary[:cart_items]).to eq(2)
        expect(summary[:cart_items_total]).to eq(8)
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
      media
      File.write(path, "previous baseline\n")
      allow(SolrDocument).to receive(:new).and_raise(ActiveRecord::StatementInvalid, 'boom')

      expect { Morphosource::DownloadReviewerExport.new(path: path, scope: 'media').call }
        .to raise_error(ActiveRecord::StatementInvalid)

      expect(File.read(path)).to eq("previous baseline\n")
      expect(Dir.glob("#{path}.*.part")).to be_empty
    end

    it 'reports a Media resolving through a dangling record and finishes the walk' do
      media
      allow_any_instance_of(SolrDocument).to receive(:reviewer)
        .and_raise(ActiveFedora::ObjectNotFoundError)

      summary = Morphosource::DownloadReviewerExport.new(path: path, scope: 'media').call

      expect(summary[:unresolvable]).to include(media.id)
      row = row_for(media)
      expect(row['stored_download_reviewer']).to eq(reviewer.ms_id)
      expect(row['resolved_reviewers']).to be_blank
    end

    it 'resolves Media reviewers without loading them from Fedora' do
      media
      expect(Media).not_to receive(:find)

      Morphosource::DownloadReviewerExport.new(path: path, scope: 'media').call

      expect(row_for(media)['resolved_reviewers']).to eq(reviewer.ms_id)
    end

    it 'resolves Media sharing a reviewer and owner with one lookup, not one per record' do
      owner = FactoryBot.create(:contributor)
      2.times { FactoryBot.create(:media, owner: owner.ms_id) }

      # The Fedora-backed lookup #resolve_reviewers' cache exists to collapse.
      expect(OrganizationCollection).to receive(:find_by).once.and_call_original

      Morphosource::DownloadReviewerExport.new(path: path, scope: 'media').call
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
