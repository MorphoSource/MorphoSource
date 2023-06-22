require 'rails_helper'
require 'spec_helper'

RSpec.describe Morphosource::Collections::OrderedMediaBehavior, type: :controller do

  let(:user)                        { FactoryBot.create(:contributor) }
  let(:media_list)                  { MediaList.create(title: ['media list'], collection_type_gid: media_list_collection_type.gid, depositor: user.ms_id) }

  let(:media1)                      { FactoryBot.create(:public_media) }
  let(:media2)                      { FactoryBot.create(:public_media) }
  let(:media3)                      { FactoryBot.create(:public_media) }
  let(:media4)                      { FactoryBot.create(:public_media) }
  let(:media5)                      { FactoryBot.create(:public_media) }

  let(:media)                       { [media1, media2, media3, media4, media5] }

  let(:params)                      { {} }

  subject { Morphosource::Collections::MediaListsController.new() }

  before do
    media.each do |m|
      m.member_of_collections += [media_list]
      m.save!
    end
    subject.instance_variable_set(:@collection, media_list)
    allow(subject).to receive(:params).and_return(params)
    allow(subject).to receive(:current_user).and_return(user)
    sign_in user
  end

  describe 'ordered_media_ids' do
    context 'reversing all media on first page' do
      before do
        params[:document] = media.map(&:id).reverse
      end
      it 'returns collection media ids with current page order' do
        ordered_media = media.map(&:id).reverse.join(',')
        expect(subject.ordered_media_ids).to eq([ordered_media])
      end
    end
    context 'reordering media on second page only' do
      before do
        params["page"] = "2"
        params["per_page"] = "3"
        params[:document] = [media5.id, media4.id]
      end
      it 'returns collection media ids with current page order' do
        ordered_media = [media1.id, media2.id, media3.id, media5.id, media4.id].join(',')
        expect(subject.ordered_media_ids).to eq([ordered_media])
      end
    end
  end

  describe 'sort_document_list' do
     let(:document_list)  { media_list.media_docs }
     before do
      media_list.ordered_media = [media.map(&:id).join(',')]
      subject.instance_variable_set(:@blacklight_config, subject.blacklight_config)
     end
     it 'returns a paginated array of the media in the same order as media_list.ordered_media' do
      media_list.ordered_media = [media.map(&:id).join(',')]
      expect([subject.sort_document_list(document_list).map{|doc| doc["id"]}.join(',')]).to match_array(media_list.ordered_media)

      media_list.ordered_media = [media.map(&:id).reverse.join(',')]
      expect([subject.sort_document_list(document_list).map{|doc| doc["id"]}.join(',')]).to match_array(media_list.ordered_media)
     end
  end
end