# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Media download reviewers', type: :request do
  let(:owner)          { FactoryBot.create(:contributor) }
  let(:reviewer)       { FactoryBot.create(:contributor) }
  let(:other_reviewer) { FactoryBot.create(:contributor) }
  let(:media_type)     { 'Image' }
  let(:media) do
    FactoryBot.create(:media, title: ['Reviewed media'], media_type: [media_type], owner: owner.ms_id,
                              depositor: owner.ms_id, edit_users: [owner.user_key],
                              visibility: 'restricted', fileset_accessibility: ['restricted_download'],
                              record_download_reviewer_users: [reviewer.ms_id, other_reviewer.ms_id])
  end
  let(:organization) do
    FactoryBot.create(:organization_collection, title: ['Eligible Org'], depositor: owner.ms_id,
                                                reviews_object_media_downloads: true)
  end
  let(:ineligible_organization) do
    FactoryBot.create(:organization_collection, title: ['Ineligible Org'], depositor: owner.ms_id)
  end
  let(:object_organizations) { [organization] }
  let(:posted_list) { "#{reviewer.ms_id},#{other_reviewer.ms_id}" }

  before do
    allow_any_instance_of(Media).to receive(:organizations).and_return(object_organizations) # rubocop:disable RSpec/AnyInstance
    sign_in owner
  end

  def patch_reviewers(mode, extra = {})
    patch "/concern/media/#{media.id}",
          params: { media: { media_type: media_type, visibility: 'restricted_download',
                             download_reviewer_mode: mode,
                             record_download_reviewer_users: [posted_list] }.merge(extra) }
  end

  it 'keeps the record list through a round trip into organization mode and back' do
    patch_reviewers('object_organization')
    expect(response).to have_http_status(:redirect)
    media.reload
    expect(media.download_reviewer_mode).to eq('object_organization')
    expect(media.record_download_reviewer_users).to match_array([reviewer.ms_id, other_reviewer.ms_id])

    patch_reviewers('record_users')
    expect(response).to have_http_status(:redirect)
    media.reload
    expect(media.download_reviewer_mode).to eq('record_users')
    expect(media.record_download_reviewer_users).to match_array([reviewer.ms_id, other_reviewer.ms_id])
    expect(media.publication_status).to eq('restricted')
  end

  context 'when an Object Organization is ineligible' do
    let(:object_organizations) { [organization, ineligible_organization] }

    it 'refuses the save and names the organization' do
      allow_any_instance_of(Hyrax::MediaPresenter).to receive(:imaging_event_modality).and_return(nil) # rubocop:disable RSpec/AnyInstance
      patch_reviewers('object_organization')

      expect(response).to have_http_status(:unprocessable_entity)
      banner = Nokogiri::HTML(response.body).at_css('.alert-danger').text
      expect(banner).to include('cannot be set to the object organization')
      expect(banner).to include('Ineligible Org')
      expect(media.reload.download_reviewer_mode).to eq('record_users')
      expect(media.publication_status).to eq('restricted')
    end
  end

  context 'on a media with a DOI, edited by a non-admin' do
    before do
      media.doi = ['10.5072/FK2/EXAMPLE']
      media.save!
    end

    it 'saves a changed reviewer list while stripping other fields' do
      description = media.description
      patch "/concern/media/#{media.id}",
            params: { media: { visibility: 'restricted_download', description: 'Changed description',
                               record_download_reviewer_users: [reviewer.ms_id] } }

      expect(response).to have_http_status(:redirect)
      media.reload
      expect(media.record_download_reviewer_users).to eq([reviewer.ms_id])
      expect(media.description).to eq(description)
      expect(media.publication_status).to eq('restricted')
    end
  end

  describe 'GET edit' do
    %w[Image Mesh].each do |type|
      context "for a #{type} media" do
        let(:media_type) { type }

        it 'renders the reviewer block' do
          allow_any_instance_of(Hyrax::MediaPresenter).to receive(:imaging_event_modality).and_return(nil) # rubocop:disable RSpec/AnyInstance
          get "/media/#{media.id}/edit"

          expect(response).to have_http_status(:ok)
          document = Nokogiri::HTML(response.body)
          expect(document.at_css('#media-download-reviewers #media_download_reviewer_mode_object_organization')).to be_present
          expect(document.at_css('#media-download-reviewers #media_record_download_reviewer_users')).to be_present
        end
      end
    end
  end
end
