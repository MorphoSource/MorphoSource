require 'rails_helper'

RSpec.describe 'batch_upload routing', type: :routing do

  it 'has a new route' do
    route = { controller: 'batch_uploads', action: 'new' }
    expect(:get => '/batch_uploads/new').to route_to(route)
    expect(:get => batch_uploads_new_path).to route_to(route)
  end

end
