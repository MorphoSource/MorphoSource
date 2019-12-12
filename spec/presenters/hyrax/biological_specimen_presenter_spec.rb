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

end
