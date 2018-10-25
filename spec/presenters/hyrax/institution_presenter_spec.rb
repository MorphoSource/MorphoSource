# Generated via
#  `rails generate hyrax:work Institution`
require 'rails_helper'

RSpec.describe Hyrax::InstitutionPresenter do
  subject { described_class.new(double, double) }

  it { is_expected.to delegate_method(:institution_code).to(:solr_document) }
  it { is_expected.to delegate_method(:address).to(:solr_document) }
  it { is_expected.to delegate_method(:city).to(:solr_document) }
  it { is_expected.to delegate_method(:state_province).to(:solr_document) }
  it { is_expected.to delegate_method(:country).to(:solr_document) }
end
