require 'rails_helper'

RSpec.describe BatchSubmissionTools::Ms2Batch::Models::MediaManifest do

  let(:depositor)       { FactoryBot.create(:contributor) }
  let(:org_collection)  { FactoryBot.create(:organization_collection, depositor: depositor.ms_id) }
  let(:owner)           { org_collection.id }

  subject { described_class.new(initial_attrs: {},
                                depositor: nil,
                                owner: owner,
                                on_behalf_of: nil,
                                organization_id: nil,
                                media_path: nil,
                                media_ownership_fields: {},
                                derived_parent_file: nil,
                                attrs: {},
                                work_imported: false) }

  describe 'attr_accessor' do
    it { is_expected.to respond_to(:owner) }
  end

  describe 'initialize' do
    it 'sets owner' do
      expect(subject.owner).to eq(owner)
    end
  end

  describe 'additional_attributes' do
    it 'carries record reviewers without accepting a legacy reviewer writer' do
      manifest = described_class.new(initial_attrs: {}, depositor: depositor.ms_id, owner: owner,
        media_ownership_fields: { 'record_download_reviewer_users' => [depositor.ms_id],
                                 'download_reviewer_mode' => 'record_users',
                                 'download_reviewer' => ['legacy-value'] })
      attributes = manifest.additional_attributes
      expect(attributes[:record_download_reviewer_users]).to eq([depositor.ms_id])
      expect(attributes[:download_reviewer_mode]).to eq('record_users')
      expect(attributes).not_to have_key(:download_reviewer)
    end

    it 'includes owner' do
      expect(subject.additional_attributes[:owner]).to eq(owner)
    end

    it 'maps publication status private to Hyrax private visibility' do
      manifest = described_class.new(
        initial_attrs: {},
        depositor: depositor.ms_id,
        owner: owner,
        media_ownership_fields: { "visibility" => "private" }
      )

      attrs = manifest.additional_attributes
      expect(attrs[:visibility]).to eq(Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE)
      expect(attrs[:fileset_accessibility]).to eq("private")
    end
  end
end
