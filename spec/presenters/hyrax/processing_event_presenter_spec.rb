# Generated via
#  `rails generate hyrax:work ProcessingEvent`
require 'rails_helper'

RSpec.describe Hyrax::ProcessingEventPresenter do

  let(:work) { ProcessingEvent.new() }

    subject { described_class.new(SolrDocument.new(work.to_solr), nil) }

    it { is_expected.to delegate_method(:software).to(:solr_document) }

end
