# Generated via
#  `rails generate hyrax:work BiologicalSpecimen`
require 'rails_helper'

RSpec.describe BiologicalSpecimen do

  describe 'metadata' do

    it_behaves_like 'a work with physical object metadata'

    it 'has biological specimen descriptive metadata' do
      expect(subject.attributes.keys).to include('idigbio_recordset_id', 'idigbio_uuid', 'is_type_specimen',
                                                 'occurrence_id', 'sex')
    end
  end

end
