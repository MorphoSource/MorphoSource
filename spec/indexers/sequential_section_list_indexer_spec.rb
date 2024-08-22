require 'rails_helper'

RSpec.describe SequentialSectionListIndexer do
  subject(:solr_document) { SequentialSectionListIndexer.new(list).generate_solr_document }

  let(:user)  { FactoryBot.create(:contributor)}
  let(:doi)   { ['10.17602/M2/L123456'] }
  let(:list)  { FactoryBot.create(:sequential_section_list,
                                  depositor: user.ms_id,
                                  doi: doi) }

  describe 'property fields' do
    it 'indexes doi' do
      expect(subject['doi_ssim']).to match_array(doi)
    end
  end

  describe 'custom fields' do
    context 'list has media' do
      let(:media)         { FactoryBot.create(:media) }
      let(:device)        { FactoryBot.create(:device) }
      let(:organization)  { FactoryBot.create(:organization) }
      let(:imaging_event) { FactoryBot.create(:imaging_event, ie_modality: ['SequentialSectionScan'], device_id: [device.id], physical_object_id: [object.id]) }

      before do
        imaging_event.ordered_members << media
        imaging_event.save!
        media.member_of_collections += [list]
        media.save!
      end

      context 'media represent a biological specimen' do
        let(:taxonomy)  { FactoryBot.create(:taxonomy, gbif_key: ['8675309'])}
        let(:object)    { FactoryBot.create(:biological_specimen, organization_id: [organization.id], taxonomy_id: [taxonomy.id], idigbio_uuid: ['12345'], occurrence_id: ['678910'])}

        it 'indexes specimen and taxonomy fields' do
          expect(subject['physical_object_type_ssim']).to match_array(["Biological Specimen"])
          expect(subject['physical_object_id_ssi']).to eq(object.id)
          expect(subject['record_source_ssim']).to match_array(['iDigBio Aggregator'])
          expect(subject['organization_id_ssim']).to match_array([organization.id])
          expect(subject['taxonomy_id_ssim']).to match_array([taxonomy.id])
          expect(subject['gbif_taxonomy_id_ssim']).to match_array([taxonomy.id])
          expect(subject['idigbio_uuid_tesim']).to match_array(object.idigbio_uuid)
          expect(subject['occurrence_id_tesim']).to match_array(object.occurrence_id)
        end
      end

      context 'media represent a cultural heritage object' do
        let(:object)  { FactoryBot.create(:cultural_heritage_object, organization_id: [organization.id]) }

        it 'indexes cultural heritage object fields' do
          expect(subject['physical_object_type_ssim']).to match_array(["Cultural Heritage Object"])
          expect(subject['physical_object_id_ssi']).to eq(object.id)
          expect(subject['record_source_ssim']).to be nil
          expect(subject['organization_id_ssim']).to match_array([organization.id])
          expect(subject['taxonomy_id_ssim']).to be nil
          expect(subject['gbif_taxonomy_id_ssim']).to be nil
          expect(subject['idigbio_uuid_tesim']).to be nil
          expect(subject['occurrence_id_tesim']).to be nil
        end
      end
    end

    context 'list does not have any media' do
      it 'does not index object fields' do
        expect(subject['physical_object_type_ssim']).to be nil
        expect(subject['physical_object_id_ssi']).to be nil
        expect(subject['record_source_ssim']).to be nil
        expect(subject['organization_id_ssim']).to be nil
        expect(subject['taxonomy_id_ssim']).to be nil
        expect(subject['gbif_taxonomy_id_ssim']).to be nil
        expect(subject['idigbio_uuid_tesim']).to be nil
        expect(subject['occurrence_id_tesim']).to be nil
      end
    end
  end
end
