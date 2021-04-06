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

      it 'has 7 facet fields' do
        expect(facet_fields.count).to eq(7)
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

      describe 'institution name' do
        subject { facet_fields['institution_name_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Institution")
          expect(subject.limit).to eq(5)
        end
      end

      describe 'institution code' do
        subject { facet_fields['institution_code_tesim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Institution Code")
          expect(subject.limit).to eq(5)
        end
      end

      describe 'country' do
        subject { facet_fields['country_tesim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Country")
          expect(subject.limit).to eq(5)
        end
      end

      describe 'state/province' do
        subject { facet_fields['state_province_tesim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("State / Province")
          expect(subject.limit).to eq(5)
        end
      end

      describe 'city' do
        subject { facet_fields['city_tesim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("City")
          expect(subject.limit).to eq(5)
        end
      end
    end

    describe 'index fields' do
      let(:index_fields)  { config.index_fields }

      describe 'type' do
        subject { index_fields['organization_type_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Type')
          expect(subject.field).to eq('organization_type_tesim')
        end
      end

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

      describe 'institution code' do
        subject { index_fields['institution_code_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Institution Code')
          expect(subject.field).to eq('institution_code_tesim')
        end
      end

      describe 'collection code' do
        subject { index_fields['collection_code_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Collection Code')
          expect(subject.field).to eq('collection_code_tesim')
        end
      end

      describe 'country' do
        subject { index_fields['country_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Country')
          expect(subject.field).to eq('country_tesim')
        end
      end
    end

    describe 'show fields' do
      let(:show_fields) { config.show_fields }
      describe 'organizations' do
        describe 'institution name' do
          subject { show_fields["institution_name_tesim"] }
          it 'has the correct attributes' do
            expect(subject.key).to eq("institution_name_tesim")
            expect(subject.field).to eq("institution_name_tesim")
            expect(subject.label).to eq("Institution Name Tesim")
          end
        end
      end
    end

    describe 'search fields' do
      let(:search_fields) { config.search_fields }
      describe 'all_fields' do
        subject { search_fields['all_fields'] }
        it 'includes institution_name' do
          expect(subject.solr_parameters[:qf]).to include('institution_name_tesim')
        end
      end
    end
  end
end
