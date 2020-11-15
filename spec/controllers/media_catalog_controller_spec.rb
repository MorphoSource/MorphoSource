require 'rails_helper'

RSpec.describe MediaCatalogController, :type => :controller do

  describe 'Blacklight Configuration' do
    let(:config) { described_class.new.blacklight_config }

    it 'is the hyrax catalog search builder' do
      expect(config.search_builder_class).to eq(Morphosource::Catalog::MediaCatalogSearchBuilder)
    end

    it 'has a thumbnail field' do
      expect(config.index.thumbnail_field).to eq('thumbnail_path_ss')
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
        subject { facet_fields['member_of_public_collection_ids_ssim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Team / Project")
          expect(subject.limit).to eq(5)
        end
      end
    end

    describe 'index fields' do
      let(:index_fields) { config.index_fields }

      describe 'title' do
        subject { index_fields['title_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Title')
          expect(subject.field).to eq('title_tesim')
        end
      end

      describe 'physical object id' do
        subject { index_fields['physical_object_id_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Object')
          expect(subject.helper_method).to eq(:link_to_object)
          expect(subject.field).to eq('physical_object_id_tesim')
        end
      end

      describe 'taxonomy' do
        subject { index_fields['taxonomy_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq("Taxonomy")
          expect(subject.field).to eq('taxonomy_tesim')
        end
      end

      describe 'part' do
        subject { index_fields['part_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq("Element or Part")
          expect(subject.field).to eq('part_tesim')
        end
      end

      describe 'modality' do
        subject { index_fields['media_modality_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Modality')
          expect(subject.field).to eq('media_modality_tesim')
        end
      end

      describe 'depositor' do
        subject { index_fields['depositor_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Owner')
          expect(subject.field).to eq('depositor_tesim')
        end
      end

      describe 'date uploaded' do
        subject { index_fields['date_uploaded_dtsi'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Date Uploaded')
          expect(subject.helper_method).to eq(:human_readable_date)
          expect(subject.field).to eq('date_uploaded_dtsi')
        end
      end

      describe 'rights statement' do
        subject { index_fields['rights_statement_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Rights Statement Tesim')
          expect(subject.helper_method).to eq(:rights_statement_links)
          expect(subject.field).to eq('rights_statement_tesim')
        end
      end
    end
  end
end
