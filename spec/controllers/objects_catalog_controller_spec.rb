# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ObjectsCatalogController, type: :controller do

  describe '#current_catalog_search_path' do
    it 'returns the objects search path' do
      expect(controller.current_catalog_search_path).to eq(object_search_path)
    end
  end

  describe 'Blacklight Configuration' do
    let(:config) { described_class.new.blacklight_config }

    it 'is the hyrax catalog search builder' do
      expect(config.search_builder_class).to eq(Morphosource::Catalog::ObjectsCatalogSearchBuilder)
    end

    it 'does not have a thumbnail path' do
      expect(config.index.thumbnail_field).to eq('')
    end

    describe 'facet fields' do
      let(:facet_fields) { config.facet_fields }

      it 'has 12 facet fields' do
        expect(facet_fields.count).to eq(12)
      end

      describe 'human readable type' do
        subject { facet_fields["object_type"] }
        it 'has the correct attributes' do
          expect(subject.label).to eq('Object Type')
          expect(subject.limit).to eq(10)
        end
      end

      describe 'creator' do
        subject { facet_fields["creator"] }
        it 'has the correct attributes' do
          expect(subject.label).to eq('Collector/Creator')
          expect(subject.limit).to eq(10)
        end
      end

      describe 'organization' do
        subject { facet_fields["organization"] }
        it 'has the correct attributes' do
          expect(subject.label).to eq('Organization')
          expect(subject.limit).to eq(10)
        end
      end

      describe 'taxonomy_name' do
        subject { facet_fields["taxonomy_name"]}
        it 'has the correct attributes' do
          expect(subject.label).to eq("Taxonomy (Name)")
          expect(subject.limit).to eq(10)
        end
      end

      describe 'taxonomy_gbif' do
        subject { facet_fields["taxonomy_gbif"]}
        it 'has the correct attributes' do
          expect(subject.label).to eq("Taxonomy (GBIF)")
          expect(subject.limit).to eq(25)
        end
      end

      describe 'media type' do
        subject { facet_fields["media_type"] }
        it 'has the correct attributes' do
          expect(subject.label).to eq('Media Type')
          expect(subject.limit).to eq(10)
        end
      end

      describe 'media tag' do
        subject { facet_fields["media_tag"] }
        it 'has the correct attributes' do
          expect(subject.label).to eq('Media Tag')
          expect(subject.limit).to eq(10)
        end
      end

      describe 'media teams' do
        subject { facet_fields["team"] }
        it 'has the correct attributes' do
          expect(subject.label).to eq('Team')
          expect(subject.limit).to eq(10)
        end
      end

      describe 'media projects' do
        subject { facet_fields["project"] }
        it 'has the correct attributes' do
          expect(subject.label).to eq('Project')
          expect(subject.limit).to eq(10)
        end
      end

      describe 'media lists' do
        subject { facet_fields["media_list"] }
        it 'has the correct attributes' do
          expect(subject.label).to eq('Media List')
          expect(subject.limit).to eq(10)
        end
      end

      describe 'media sequential section lists' do
        subject { facet_fields["seq_section_list"] }
        it 'has the correct attributes' do
          expect(subject.label).to eq('Seq. Section List')
          expect(subject.limit).to eq(10)
        end
      end
    end

    describe 'index fields' do
      let(:index_fields)  { config.index_fields }

      describe 'title' do
        subject { index_fields['title_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Title')
          expect(subject.field).to eq('title_tesim')
        end
      end

      describe 'taxonomy' do
        subject { index_fields['taxonomy_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Taxonomy')
          expect(subject.field).to eq('taxonomy_tesim')
        end
      end

      describe 'organization' do
        subject { index_fields['organization_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Organization')
          expect(subject.field).to eq('organization_tesim')
        end
      end

      describe 'type' do
        subject { index_fields['human_readable_type_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Type')
          expect(subject.field).to eq('human_readable_type_tesim')
        end
      end

      describe 'source' do
        subject { index_fields['source'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Source')
          expect(subject.field).to eq('source')
          expect(subject.accessor).to eq('object_record_source')
        end
      end
    end

    describe 'show fields' do
      let(:show_fields) { config.show_fields }
      describe 'objects' do
        describe 'taxonomy' do
          subject { show_fields["taxonomy_tesim"] }
          it 'has the correct attributes' do
            expect(subject.key).to eq("taxonomy_tesim")
            expect(subject.field).to eq("taxonomy_tesim")
            expect(subject.label).to eq("Taxonomy Tesim")
          end
        end
      end
    end

    describe 'search fields' do
      let(:search_fields) { config.search_fields }
      describe 'all_fields' do
        subject { search_fields['all_fields'] }
        it 'includes taxonomy' do
          expect(subject.solr_parameters[:qf]).to include('taxonomy_tesim')
        end
      end
    end
  end

  describe '#show_by_occurrence_id JSON API endpoint' do
    context 'with a matching public biological specimen' do
      let!(:document) do
        create(:biological_specimen_document,
               occurrence_id_ssim: ['test-occurrence-abc'],
               read_access_group_ssim: ['public'])
      end

      it 'returns 200 with biological_specimen data' do
        get :show_by_occurrence_id, params: { occurrence_id: 'test-occurrence-abc' }, format: :json
        expect(response.content_type).to include('application/json')
        expect(response.code).to eq("200")
        expect(JSON.parse(response.body).dig("response", "biological_specimen")).to be_present
      end
    end

    context 'when no physical object matches the occurrence_id' do
      it 'returns 404' do
        get :show_by_occurrence_id, params: { occurrence_id: 'urn:no:match:here' }, format: :json
        expect(response.content_type).to include('application/json')
        expect(response.code).to eq("404")
      end
    end
  end
end
