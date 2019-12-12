
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
      let(:parent) { ImagingEvent.new(title: ["Example Parent Imaging Event Work"]) }
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
