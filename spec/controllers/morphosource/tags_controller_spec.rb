require 'rails_helper'
include ActionDispatch::TestProcess
include Warden::Test::Helpers

RSpec.describe Morphosource::TagsController, type: :controller do
  let(:media1)  { Media.create(title: ['media1'], keyword: ['apple', 'banana', 'cherry'], visibility: 'open', fileset_accessibility: ['open']) }
  let(:media2)  { Media.create(title: ['media1'], keyword: ['apple', 'banana', 'cherry'], visibility: 'open', fileset_accessibility: ['open']) }

  before do
    ActiveFedora::SolrService.add(media1.to_solr, commit: true)
    ActiveFedora::SolrService.add(media2.to_solr, commit: true)
  end


  describe '#index' do
    before do
      get :index, format: :json, params: params
    end

    context 'uq is empty' do
      let(:params)  { { uq: '' } }
      it 'returns previously created keywords' do
        expect(controller.instance_variable_get(:@tags)).to eq(["apple", 2, "banana", 2, "cherry", 2])
      end
    end

    context 'uq is not empty' do
      let(:params)  { { uq: 'ban' } }
      it 'returns matching keywords' do
        expect(controller.instance_variable_get(:@tags)).to eq(["banana", 2])
      end
    end
  end

  describe '#show' do
    let(:user)    { User.create(email: 'user@email.com', password: 'password') }
    let(:params)  { { tag: 'apple' } }

    before do
      sign_in user
      get :show, params: params
    end

    it 'returns all media with the tag' do
      expect(controller.instance_variable_get(:@document_count)).to eq(2)
    end

    it 'returns only media that have the tag' do
      docs = controller.instance_variable_get(:@documents)
      docs.each do |doc|
        expect(doc.keyword).to include('apple')
      end
    end

    it 'renders the show page' do
      expect(response).to render_template("morphosource/tags/show")
    end

  end
end
