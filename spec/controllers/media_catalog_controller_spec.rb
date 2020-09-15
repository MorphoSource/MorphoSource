require 'rails_helper'

RSpec.describe MediaCatalogController, :type => :controller do

  describe 'access_controlled_facets' do
    it { expect(controller.access_controlled_facets).to match_array(['member_of_collection_ids_ssim']) }
  end

  describe 'Blacklight Configuration' do
    let(:config) { described_class.new.blacklight_config }
    describe 'search_builder_class' do
      it 'is the hyrax catalog search builder' do
        expect(config.search_builder_class).to eq(Morphosource::Catalog::MediaCatalogSearchBuilder)
      end
    end
    describe 'facet fields' do
      let(:facet_fields) { config.facet_fields }

      it 'has 7 facet fields' do
        expect(facet_fields.count).to eq(7)
      end

      describe 'generic type' do
        subject { facet_fields['generic_type_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Generic Type Sim")
        end
      end

      describe 'human readable media type' do
        subject { facet_fields['human_readable_media_type_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Type")
          expect(subject.limit).to eq(5)
        end
      end

      describe 'modality' do
        subject { facet_fields['media_modality_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Modality")
          expect(subject.limit).to eq(6)
        end
      end

      describe 'physical object type' do
        subject { facet_fields['media_physical_object_type_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Object Type")
          expect(subject.limit).to eq(5)
        end
      end

      describe 'organization' do
        subject { facet_fields['media_organization_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Organization")
          expect(subject.limit).to eq(5)
        end
      end

      describe 'keyword' do
        subject { facet_fields['keyword_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Tag")
          expect(subject.limit).to eq(5)
        end
      end

      describe 'member of collections' do
        subject { facet_fields['member_of_collection_ids_ssim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Team / Project")
          expect(subject.limit).to eq(5)
        end
      end
    end
  end
end
