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
    let!(:object)   { CulturalHeritageObject.create(title: ['bso'], vouchered: ['Yes']) }
    let!(:media1)   { Media.create(title: ['media1'], visibility: 'open', physical_object_id: [object.id]) }
    let!(:media2)   { Media.create(title: ['media2'], visibility: 'restricted', physical_object_id: [object.id]) }
    let!(:user)     { User.create(id: 'user', email: 'email@email.com', password: 'password') }
    let!(:ability)  { Ability.new(user) }

    subject { described_class.new(SolrDocument.new(object.to_solr), ability, nil) }

    it 'returns the number of viewable media' do
      expect(subject.total_viewable_media).to eq(1)
    end
  end
end
