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

end
