# Generated via
#  `rails generate hyrax:work Device`
require 'rails_helper'

RSpec.describe Hyrax::DevicePresenter do
  subject { described_class.new(double, double) }
  it { is_expected.to delegate_method(:modality).to(:solr_document) }
  it { is_expected.to delegate_method(:ark).to(:solr_document) }
  it { is_expected.to delegate_method(:device_organization_id).to(:solr_document) }
end
