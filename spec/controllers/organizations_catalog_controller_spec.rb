require 'rails_helper'

RSpec.describe OrganizationsCatalogController, :type => :controller do

  describe 'Blacklight Configuration' do
    let(:config) { described_class.new.blacklight_config }

    it 'is the hyrax catalog search builder' do
      expect(config.search_builder_class).to eq(Morphosource::Catalog::OrganizationsCatalogSearchBuilder)
    end

    it 'does not have a thumbnail path' do
      expect(config.index.thumbnail_field).to eq('')
    end

    describe 'facet fields' do
      let(:facet_fields) { config.facet_fields }

      it 'has 5 facet fields' do
        expect(facet_fields.count).to eq(5)
      end

      describe 'generic type' do
        subject { facet_fields['generic_type_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Generic Type Sim")
        end
      end

      describe 'organization type' do
        subject { facet_fields['organization_type_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Type")
          expect(subject.limit).to eq(5)
        end
      end
    end

    describe 'index fields' do
      let(:index_fields)  { config.index_fields }

      describe 'title' do
        subject { index_fields['title_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq("Title")
          expect(subject.field).to eq('title_tesim')
        end
      end

      describe 'institution' do
        subject { index_fields['institution_name_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Institution')
          expect(subject.field).to eq('institution_name_tesim')
        end
      end

      describe 'country' do
        subject { index_fields['country_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Country')
          expect(subject.field).to eq('country_tesim')
        end
      end

      describe 'type' do
        subject { index_fields['organization_type_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Type')
          expect(subject.field).to eq('organization_type_tesim')
        end
      end
    end
  end
end
