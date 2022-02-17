# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ObjectsCatalogController, type: :controller do

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

      it 'has 9 facet fields' do
        expect(facet_fields.count).to eq(9)
      end

      describe 'human readable type' do
        subject { facet_fields['human_readable_type_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq('Type')
          expect(subject.limit).to eq(10)
        end
      end

      describe 'creator' do
        subject { facet_fields['creator_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq('Creator')
          expect(subject.limit).to eq(10)
        end
      end

      describe 'organization' do
        subject { facet_fields['organization_ssim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq('Organization')
          expect(subject.limit).to eq(10)
        end
      end

      describe 'media type' do
        subject { facet_fields['public_media_type_ssim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq('Media Type')
          expect(subject.limit).to eq(10)
        end
      end

      describe 'media teams' do
        subject { facet_fields['media_member_of_team_ids_ssim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq('Team')
          expect(subject.limit).to eq(10)
        end
      end

      describe 'media projects' do
        subject { facet_fields['media_member_of_project_ids_ssim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq('Project')
          expect(subject.limit).to eq(10)
        end
      end

      describe 'media keyword' do
        subject { facet_fields['public_media_keyword_ssim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq('Media Tag')
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
end
