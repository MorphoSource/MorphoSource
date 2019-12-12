require 'iiif_manifest'
require 'rails_helper'

RSpec.describe Hyrax::MediaFileSetPresenter do
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:ability) { double "Ability" }
  let(:presenter) { described_class.new(solr_document, ability, request) }
  let(:user) { double(user_key: 'julie') }
  let(:request) { double(base_url: 'http://test.host') }
  let(:id) { '999' }
  let(:read_permission) { true }

  let(:attributes) { {
              id: '999',
              creator_tesim: ['Doe, John', 'Doe, Jane'],
              date_modified_dtsi: '2011-04-01',
              has_model_ssim: ['Media'],
              depositor_tesim: user.user_key,
              description_tesim: ['Lorem ipsum lorem ipsum.'],
              keyword_tesim: ['bacon', 'sausage', 'eggs'],
              rights_statement_tesim: ['http://example.org/rs/1'],
              date_created_tesim: ['1984-01-02']
             } }

  describe 'IIIF integration' do
    before do
      allow(ability).to receive(:can?).with(:read, solr_document.id).and_return(read_permission)
    end

    describe "#display_mesh" do
      subject { presenter.display_mesh }

      context 'without a file' do
        let(:id) { 'bogus' }
        it { is_expected.to be_nil }
      end

      context 'with a file' do
        context "when the file is not an image" do
          before do
            attributes[:title_tesim] = ['test.txt']
          end
          it { is_expected.to be_nil }
        end

        context "when the user doesn't have permission to view the image" do
          before do
            attributes[:title_tesim] = ['test.png']
          end
          let(:read_permission) { false }
          it { is_expected.to be_nil }
        end

        context "when the file is a mesh" do
          before do
            attributes[:title_tesim] = ['test.ply']
            attributes[:label_tesim] = ['test.ply']
            allow(solr_document).to receive(:mesh?).and_return(true)
            allow(::FileSet).to receive(:exists?).with(solr_document.id).and_return(true)
          end

          it { is_expected.to be_instance_of IIIFManifest::DisplayMesh }
          its(:url) { is_expected.to eq "/downloads/#{id}?file=glb" }
        end
      end
    end

    describe "#display_volume" do
      subject { presenter.display_volume }

      context 'without a file' do
        let(:id) { 'bogus' }
        it { is_expected.to be_nil }
      end

      context 'with a file' do
        context "when the file is not an image" do
          before do
            attributes[:title_tesim] = ['test.txt']
          end
          it { is_expected.to be_nil }
        end

        context "when the user doesn't have permission to view the image" do
          before do
            attributes[:title_tesim] = ['test.png']
          end
          let(:read_permission) { false }
          it { is_expected.to be_nil }
        end

        context "when the file is a volume" do
          before do
            attributes[:title_tesim] = ['test.zip']
            attributes[:label_tesim] = ['test.zip']
            allow(solr_document).to receive(:volume?).and_return(true)
            allow(::FileSet).to receive(:exists?).with(solr_document.id).and_return(true)
          end

          it { is_expected.to be_instance_of IIIFManifest::DisplayVolume }
          its(:url) { is_expected.to eq "/downloads/#{id}?file=dcm" }
        end
      end
    end
  end
end
