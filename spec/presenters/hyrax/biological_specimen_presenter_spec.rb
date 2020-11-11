# Generated via
#  `rails generate hyrax:work BiologicalSpecimen`
require 'rails_helper'

RSpec.describe Hyrax::BiologicalSpecimenPresenter do

  let(:work) { BiologicalSpecimen.new() }
  let(:bso_terms) {[:idigbio_recordset_id, :idigbio_uuid, :is_type_specimen, :occurrence_id, :sex]}
  let(:taxonomy_methods) {[:taxonomies, :canonical_taxonomy_object, :trusted_taxonomies, :user_taxonomies]}

  subject { described_class.new(SolrDocument.new(work.to_solr), nil) }

  it_behaves_like 'a physical object presenter'

  it 'delegates all metadata terms to solr' do
    bso_terms.each do |method|
      expect(subject).to delegate_method(method).to(:solr_document)
    end
  end

  it 'delegates taxonomy methods to work' do
    taxonomy_methods.each do |method|
      expect(subject).to delegate_method(method).to(:work)
    end
  end

  describe 'total_viewable_media' do
    let!(:object)   { BiologicalSpecimen.create(title: ['bso'], vouchered: ['Yes']) }
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
