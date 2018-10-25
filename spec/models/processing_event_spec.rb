# Generated via
#  `rails generate hyrax:work ProcessingEvent`
require 'rails_helper'

RSpec.describe ProcessingEvent do

  it_behaves_like 'a Morphosource work'

  describe 'metadata' do

    it "has descriptive metadata" do

      expect(subject).to respond_to(:creator)
      expect(subject).to respond_to(:date_created)
      expect(subject).to respond_to(:description)
      expect(subject).to respond_to(:software)
      expect(subject).to respond_to(:title)

    end

  end

end
