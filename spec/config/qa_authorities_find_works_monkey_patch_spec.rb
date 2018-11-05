require 'rails_helper'

RSpec.describe Qa::Authorities::FindWorks do

  it 'uses a custom search builder' do
    expect(described_class.search_builder_class).to eq(::FindWorksSearchBuilder)
  end

end
