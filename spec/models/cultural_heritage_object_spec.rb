# Generated via
#  `rails generate hyrax:work CulturalHeritageObject`
require 'rails_helper'

RSpec.describe CulturalHeritageObject do

  it_behaves_like 'a Morphosource work'

  describe 'metadata' do

    it_behaves_like 'a work with physical object metadata'

    it 'has cultural heritage object metadata' do
      expect(subject.attributes.keys).to include('cho_type', 'material', 'short_title')
    end

  end

end
