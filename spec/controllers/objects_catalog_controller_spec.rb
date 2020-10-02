# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ObjectsCatalogController, type: :controller do

  describe 'Blacklight Configuration' do
    let(:config) { described_class.new.blacklight_config }

     describe 'search_builder_class' do
      it 'is the hyrax catalog search builder' do
        expect(config.search_builder_class).to eq(Morphosource::Catalog::ObjectsCatalogSearchBuilder)
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
          expect(subject.label).to eq('Generic Type Sim')
        end
      end

      describe 'human readable type' do
        subject { facet_fields['human_readable_type_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq('Type')
          expect(subject.limit).to eq(5)
        end
      end

      describe 'creator' do
        subject { facet_fields['creator_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq('Creator')
          expect(subject.limit).to eq(5)
        end
      end

      describe 'organization' do
        subject { facet_fields['organization_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq('Organization')
          expect(subject.limit).to eq(5)
        end
      end

      describe 'media type' do
        subject { facet_fields['public_media_type_ssim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq('Media Type')
          expect(subject.limit).to eq(5)
        end
      end

      describe 'media collections' do
        subject { facet_fields['media_member_of_public_collection_ids_ssim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq('Media Team / Project')
          expect(subject.limit).to eq(5)
        end
      end

      describe 'media keyword' do
        subject { facet_fields['public_media_keyword_ssim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq('Media Tag')
          expect(subject.limit).to eq(5)
        end
      end
    end
  end
end
