require 'rails_helper'
include ActionDispatch::TestProcess

RSpec.describe Morphosource::My::FundCodesController, :type => :controller do
  describe 'PATCH #update' do
    let(:creator) { User.create(email: 'creator@email.com', password: 'password')}
    let(:user) { User.create(email: 'user@email.com', password: 'password')}
    let(:fc) { FundCode.new(title: 'Test Title', description: 'Test Description', user: creator)}

    before do 
      allow(controller).to receive(:current_user) { user }
      fc.add_user(user, true)
      fc.save!
    end

    context 'with updated members' do
      let(:member1) { User.create(email: 'member1@email.com', password: 'password')}
      let(:member2) { User.create(email: 'member2@email.com', password: 'password')}
      let(:update_params) { 
        { 
          id: fc.id,
          fund_code: 
          { 
            standard_members: "#{member1.user_key},#{member2.user_key}" 
          }
        } 
      }

      it 'successfully updates attributes' do
        patch :update, params: update_params
        fc.reload
        expect(fc.managers).to match_array([user])
        expect(fc.standard_members).to match_array([member1, member2])
      end
    end
  end
end