require 'rails_helper'
RSpec.describe ContentDepositorChangeEventJob do

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe 'perform' do
    let!(:work)         { Media.create(title: ['media']) }
    let(:sending_user)  { User.create(email: 'sendinguser@email.com', password: 'password') }

    context 'receiving user is a user' do
      let(:user)  { User.create(email: 'user@email.com', password: 'password') }

      context 'sending_user exsists' do
        it 'calls log_profile_event on sending_user' do
          expect(sending_user).to receive(:log_profile_event)
          expect(user).to receive(:log_event)
          described_class.perform_now(work, user, false, sending_user)
        end
      end

      context 'sending_user does not exist' do
        it 'does not call log_profile_event on sending_user' do
          expect(sending_user).not_to receive(:log_profile_event)
          expect(user).to receive(:log_event)
          described_class.perform_now(work, user)
        end
      end
    end

    context 'receiving user is an organization' do
      let(:depositor) { FactoryBot.create(:contributor) }
      let!(:user)     { FactoryBot.create(:organization_collection, depositor: depositor.ms_id) }

      context 'sending_user exsists' do
        it 'calls log_profile_event on sending_user' do
          expect(sending_user).to receive(:log_profile_event)
          described_class.perform_now(work, user, false, sending_user)
        end
      end

      context 'sending_user does not exist' do
        it 'does not call log_profile_event on sending_user' do
          expect(sending_user).not_to receive(:log_profile_event)
          described_class.perform_now(work, user)
        end
      end
    end
  end
end
