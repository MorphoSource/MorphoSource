# Generated via
#  `rails generate hyrax:work_resource DeviceResource`
require 'rails_helper'

RSpec.describe DeviceResourceForm do
  subject { described_class }

  it "includes expected form behaviors" do
    expect(subject.included_modules).to include(
      Morphosource::ValkyrieFormBehavior,
      SingleValuedResourceForm
    )
  end

end
