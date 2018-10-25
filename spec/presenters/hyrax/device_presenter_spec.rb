# Generated via
#  `rails generate hyrax:work Device`
require 'rails_helper'

RSpec.describe Hyrax::DevicePresenter do
  subject { described_class.new(double, double) }
  it { is_expected.to delegate_method(:facility).to(:solr_document) }
  it { is_expected.to delegate_method(:modality).to(:solr_document) }
end
