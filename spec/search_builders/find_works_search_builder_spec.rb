require 'rails_helper'

RSpec.describe FindWorksSearchBuilder do

  it 'does not limit the search to works deposited by current user' do
    expect(described_class.default_processor_chain).to_not include(:show_only_resources_deposited_by_current_user)
  end

end
