require 'rails_helper'

RSpec.describe 'dashboard admin appearance routing', type: :routing do

  # banner configuration
  context 'banner configuration' do
    let(:show)    { { controller: 'morphosource/admin/appearance/banners', action: 'show' } }
    let(:update)  { { controller: 'morphosource/admin/appearance/banners', action: 'update' } }

    it 'has the necessary routes' do
      expect(:get => '/admin/banner').to route_to(show)
      expect(:patch => '/admin/banner').to route_to(update)
    end
  end

  # homepage configuration
  context 'homepage configuration' do
    let(:show)    { { controller: 'morphosource/admin/appearance/homepage', action: 'show' } }
    let(:update)  { { controller: 'morphosource/admin/appearance/homepage', action: 'update' }}

    it 'has the necessary routes' do
      expect(:get => '/admin/homepage').to route_to(show)
      expect(:patch => '/admin/homepage').to route_to(update)
    end
  end

  # modal configuration
  context 'sitewide modal configuration' do
    let(:show)          { { controller: 'morphosource/admin/appearance/modals', action: 'show' } }
    let(:update)        { { controller: 'morphosource/admin/appearance/modals', action: 'update' } }

    it 'has the necessary routes' do
      expect(:get => '/admin/modal').to route_to(show)
      expect(:patch => '/admin/modal').to route_to(update)
    end
  end

  context 'download modal configuration' do
    let(:show)          { { controller: 'morphosource/admin/appearance/modals/download_modals', action: 'show' } }
    let(:update)        { { controller: 'morphosource/admin/appearance/modals/download_modals', action: 'update' } }

    it 'has the necessary routes' do
      expect(:get => '/admin/download_modal').to route_to(show)
      expect(:patch => '/admin/download_modal').to route_to(update)
    end
  end



end
