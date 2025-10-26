require 'rails_helper'
RSpec.describe Morphosource::FindExtraSolrJob do

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe 'perform' do
    let(:buffer)      { StringIO.new() }
    let(:filename)    { "extra_solr_docs.txt" }
    let(:date_today)  { Date.today.strftime("%Y/%m/%d") }
    let(:text)        { "This file was created by Morphosource::FindExtraSolrJob on #{date_today}. Fedora was not able to find these ids: " }

    before do
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with(filename,'w').and_yield(buffer)
    end

    context 'No missing objects are found' do
      it 'writes missing ids to extra_solr_docs.txt' do
        described_class.perform_now
        expect(buffer.string).to eq(text)
      end
    end

    context 'Missing objects are found' do
      let!(:media)                { Media.create(title: ['media']) }
      let!(:specimen)             { BiologicalSpecimen.create(title: ['specimen'], vouchered: ['Yes']) }
      let!(:taxonomy)             { valkyrie_create(:taxonomy_resource, title: ['taxonomy']) }
      let!(:cho)                  { CulturalHeritageObject.create(title: ['cho'], vouchered: ['Yes']) }
      let!(:organization)         { Organization.create(title: ['organization']) }
      let!(:device)               { Device.create(title: ['device'], modality: ['Photogrammetry']) }
      let!(:imaging_event)        { ImagingEvent.create(title: ['imaging event'], device_id: [device.id], ie_modality: device.modality) }
      let!(:processing_event)     { ProcessingEvent.create(title: ['processing event']) }

      let!(:media_id)             { media.id }
      let!(:specimen_id)          { specimen.id }
      let!(:taxonomy_id)          { taxonomy.id }
      let!(:cho_id)               { cho.id }
      let!(:organization_id)      { organization.id }
      let!(:device_id)            { device.id }
      let!(:imaging_event_id)     { imaging_event.id }
      let!(:processing_event_id)  { processing_event.id }

      let(:works)                 { [media, specimen, cho, taxonomy, organization, device, imaging_event, processing_event] }

      let(:ids)                   {
                                    { media_id => "Media",
                                      specimen_id => "BiologicalSpecimen",
                                      taxonomy_id.to_s => "Taxonomy",
                                      cho_id => "CulturalHeritageObject",
                                      organization_id => "Organization",
                                      device_id => "Device",
                                      imaging_event_id => "ImagingEvent",
                                      processing_event_id => "ProcessingEvent" }
                                    }

      before do
        works.select { |w| !w.is_a?(TaxonomyResource) }.each(&:destroy)
        ids.each do |id, model|
          ActiveFedora::SolrService.add( { "id" => id, "has_model_ssim" => model }, commit: true)
        end
      end

      it 'writes missing ids to extra_solr_docs.txt' do
        described_class.perform_now
        expect(buffer.string).to include(text)
        ids.each do |id, model|
          expect(buffer.string).to include(id)
        end
      end

      context 'Solr documents are deleted after the job has started to run' do
        let(:ids_except_media) { ids.except(media.id) }

        before do
          ActiveFedora::SolrService.delete(media.id)
        end

        it 'skips checking those fedora objects' do
          described_class.perform_now
          expect(buffer.string).to include(text)
          ids_except_media.each do |id, model|
            expect(buffer.string).to include(id)
          end
          expect(buffer.string).not_to include(media.id)
        end
      end
    end
  end
end
