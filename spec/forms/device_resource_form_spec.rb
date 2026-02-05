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

  it "validates title presence with a custom message" do
    validators = subject.validators_on(:title).grep(ActiveModel::Validations::PresenceValidator)
    messages = validators.map { |validator| validator.options[:message] }
    expect(messages).to include('Your device must have a model name.')
  end
end
