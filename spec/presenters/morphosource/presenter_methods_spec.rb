
require 'rails_helper'

# Uses Media for example work

RSpec.describe Hyrax::MediaPresenter do
  let(:solr_document) { SolrDocument.new }
  let(:request) { double(host: 'example.org') }
  let(:user) { FactoryBot.build(:user) }
  let(:ability) { Ability.new(user) }

  subject { described_class.new(solr_document, ability, request) }

  describe '#grouped_work_presenters' do
    describe 'nested work' do
      let(:parent_doc) { SolrDocument.new('has_model_ssim' => 'Media') }
      let(:parent_work_presenter) { described_class.new(parent_doc, ability, request) }
      before do
        allow(subject).to receive(:in_work_presenters) { [ parent_work_presenter ] }
      end
      it 'has a work presenter for the Media group' do
        expect(subject.grouped_work_presenters).to include('media' => [ parent_work_presenter ] )
      end
    end
  end

  describe '#in_work_presenters' do
    describe 'nested work' do
      let(:device) { Device.create(title: ['device'], modality: ['Photogrammetry']) }
      let(:parent) { ImagingEvent.new(title: ["Example Parent Imaging Event Work"], device_id: [device.id], ie_modality: device.modality) }
      let(:child) { Media.create(title: ["Example Child Media Work"]) }
      subject { described_class.new(SolrDocument.find(child.id), ability, request) }

      before do
        parent.ordered_members << child
        parent.save!
        child.reload
      end

      it 'has a work presenter' do
        expect(subject.in_work_presenters).to include(an_instance_of(Hyrax::WorkShowPresenter))
      end
    end
  end

end

RSpec.describe Hyrax::BiologicalSpecimenPresenter do
  let!(:user)           { FactoryBot.build(:user) }
  let!(:specimen)       { BiologicalSpecimen.create(title: ['specimen'], vouchered: ['Yes'] )}
  let!(:device)         { Device.create(title: ['device'], modality: ['Photogrammetry']) }
  let!(:imaging_event)  { ImagingEvent.create(title: ['imaging event'], physical_object_id: [specimen.id], visibility: 'open', ie_modality: device.modality, device_id: [device.id]) }
  let!(:imaging_event2) { ImagingEvent.create(title: ['imaging event 2'], physical_object_id: [specimen.id], visibility: 'open', ie_modality: device.modality, device_id: [device.id]) }
  let!(:media)          { Media.create(title: ['media'], visibility: 'open') }
  let!(:media2)         { Media.create(title: ['media2'], visibility: 'restricted') }
  let!(:solr_document)  { SolrDocument.find(specimen.id) }
  let!(:request)        { double(host: 'example.org') }
  let!(:ability)        { Ability.new(user) }
  subject { described_class.new(solr_document, ability, request) }

  describe 'total_viewable_media' do
    before do
      imaging_event.ordered_members << media
      imaging_event2.ordered_members << media2
      [imaging_event, imaging_event2, media, media2].each(&:save!)
    end
    context 'one media is open' do
      context 'user has no special access to the restricted media' do
        it 'returns the count of media for a po viewable by the current ability' do
          expect(subject.total_viewable_media).to eq(1)
        end
      end
      context 'user is able to discover the restricted media' do
        before do
          media2.read_users += [user]
          media2.save
        end
        it 'returns the count of media for a po viewable by the current ability' do
          expect(subject.total_viewable_media).to eq(2)
        end
      end
    end
  end
end
