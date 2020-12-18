# Generated via
#  `rails generate hyrax:work CulturalHeritageObject`
require 'rails_helper'

RSpec.describe Hyrax::CulturalHeritageObjectPresenter do

  let(:work) { CulturalHeritageObject.new() }

  subject { described_class.new(SolrDocument.new(work.to_solr), nil) }

  it_behaves_like 'a physical object presenter'

  it { is_expected.to delegate_method(:cho_type).to(:solr_document) }
  it { is_expected.to delegate_method(:material).to(:solr_document) }
  it { is_expected.to delegate_method(:short_title).to(:solr_document) }

  describe 'total_viewable_media' do
    let!(:object)           { CulturalHeritageObject.create(title: ['cho'], vouchered: ['Yes']) }
    let!(:device)           { Device.create(title: ['device'], modality: ['Photogrammetry']) }
    let!(:imaging_event)    { ImagingEvent.create(title: ['imaging event'], device_id: [device.id], ie_modality: device.modality) }
    let!(:processing_event) { ProcessingEvent.create(title: ['processing_event']) }
    let!(:media1)           { Media.create(title: ['media1'], visibility: 'restricted') }
    let!(:media2)           { Media.create(title: ['media2'], visibility: 'open') }
    let!(:user)             { User.create(id: 'user', email: 'email@email.com', password: 'password') }
    let!(:ability)          { Ability.new(user) }
    let(:works)             { [object, imaging_event, media1, processing_event, media2] }

    subject { described_class.new(SolrDocument.new(object.to_solr), ability, nil) }

    before do
      object.ordered_members << imaging_event
      imaging_event.ordered_members << media1
      media1.ordered_members << processing_event
      processing_event.ordered_members << media2
      works.each(&:save)
    end

    it 'returns the number of viewable media' do
      expect(subject.total_viewable_media).to eq(1)
    end
  end
end
