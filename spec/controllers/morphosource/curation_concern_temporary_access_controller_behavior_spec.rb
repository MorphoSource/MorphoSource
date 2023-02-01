require 'rails_helper'

RSpec.describe Morphosource::CurationConcernTemporaryAccessControllerBehavior, type: :controller do
  let(:controller) { Morphosource::ManifestsController }
  let(:cookie_jar) { ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar }
  subject { controller.new }

  let(:manager_user)  { create(:confirmed_user) }
  let(:media) { create(:media, depositor: manager_user.ms_id ) }
  let(:temporary_link) { create(:temporary_media_access_link, user: manager_user, media_id: media.id )} 

  before do
    allow(subject).to receive(:cookies).and_return(cookie_jar)
  end

  describe '#temporary_link_cookie_exists?' do
    it 'detects temporary media access cookie if cookie is present' do
      cookie_jar.encrypted[temporary_link.media_id] = { 
        value: temporary_link.token, 
        expires: temporary_link.expires_at
      }

      expect(subject.send(:temporary_link_cookie_exists?, media.id)).to be true
    end

    it 'does not detect temporary media access cookie if no cookie present' do
      expect(subject.send(:temporary_link_cookie_exists?, media.id)).to be false
    end
  end

  describe '#authorize_with_temporary_link_if_present' do
    let(:ability) { Ability.new(nil) }

    before do
      allow(subject).to receive(:current_ability).and_return(ability)
    end

    it 'adds temporary link to current_ability when cookie is present' do
      cookie_jar.encrypted[temporary_link.media_id] = { 
        value: temporary_link.token, 
        expires: temporary_link.expires_at
      }

      subject.send(:authorize_with_temporary_link_if_present, media.id)

      expect(subject.current_ability.temporary_media_access_link).to eq(temporary_link)
    end

    it 'does not add temporary link to current_ability when no cookie present' do
      subject.send(:authorize_with_temporary_link_if_present, media.id)
      expect(subject.current_ability.temporary_media_access_link).to be nil
    end
  end
end