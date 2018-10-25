# Generated via
#  `rails generate hyrax:work BiologicalSpecimen`
require 'rails_helper'

RSpec.describe Hyrax::BiologicalSpecimenPresenter do

  let(:work) { BiologicalSpecimen.new() }

  subject { described_class.new(SolrDocument.new(work.to_solr), nil) }

  it_behaves_like 'a physical object presenter'

  it { is_expected.to delegate_method(:idigbio_recordset_id).to(:solr_document) }
  it { is_expected.to delegate_method(:idigbio_uuid).to(:solr_document) }
  it { is_expected.to delegate_method(:is_type_specimen).to(:solr_document) }
  it { is_expected.to delegate_method(:occurrence_id).to(:solr_document) }
  it { is_expected.to delegate_method(:sex).to(:solr_document) }

end
