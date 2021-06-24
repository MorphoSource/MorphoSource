require 'rails_helper'
include ActionDispatch::TestProcess

RSpec.describe Morphosource::Admin::FundCodesController, :type => :controller do
  describe 'POST #create' do
    let(:user) { User.create(email: 'user@email.com', password: 'password')}

    before do 
      allow(controller).to receive(:current_user) { user }
    end

    context 'with required parameters but no members' do
      let(:post_params) { 
        { fund_code: 
          { 
            title: 'Test Title', 
            description: 'Test Description',
            external_user: false,
            chargeable: false
          }
        } 
      }

      before do 
        allow(controller).to receive(:require_permissions) { true }
      end

      it 'creates a new FundCode' do
        expect{
          process :create, method: :post, params: post_params
        }.to change{FundCode.count}.by(1)
      end 

      it 'creates the correct metadata' do
        post :create, params: post_params
        fc = FundCode.last
        expect(fc.title).to eq('Test Title')
        expect(fc.description).to eq('Test Description')
      end
    end

    context 'with required parameters and members' do
      let(:manager) { User.create(email: 'manager@email.com', password: 'password')}
      let(:member1) { User.create(email: 'member1@email.com', password: 'password')}
      let(:member2) { User.create(email: 'member2@email.com', password: 'password')}
      let(:post_params) { 
        { fund_code: 
          { 
            title: 'Test Title', 
            description: 'Test Description',
            external_user: false,
            chargeable: false,
            managers: manager.user_key.to_s, 
            standard_members: "#{member1.user_key},#{member2.user_key}"
          } 
        } 
      }

      before do 
        allow(controller).to receive(:require_permissions) { true }
      end

      it 'creates a new FundCode' do
        expect{
          process :create, method: :post, params: post_params
        }.to change{FundCode.count}.by(1)
      end 

      it 'creates the correct metadata and memberships' do
        post :create, params: post_params
        fc = FundCode.last
        expect(fc.title).to eq('Test Title')
        expect(fc.description).to eq('Test Description')
        expect(fc.managers).to match_array([manager])
        expect(fc.standard_members).to match_array([member1, member2])
      end
    end

    context 'when user is not authorized to read admin dashboard' do
      let(:post_params) { 
        { fund_code: 
          { 
            title: 'Test Title', 
            description: 'Test Description',
            external_user: false,
            chargeable: false
          }
        } 
      }

      it 'does not create a new FundCode' do
        expect{
          process :create, method: :post, params: post_params
        }.to change{FundCode.count}.by(0)
      end 
    end
  end

  describe 'PATCH #update' do
    let(:user) { User.create(email: 'user@email.com', password: 'password')}
    let(:fc) { FundCode.new(title: 'Test Title', description: 'Test Description', chargeable: false, user: user)}

    before do 
      allow(controller).to receive(:current_user) { user }
      fc.save!
    end

    context 'with updated metadata attributes' do
      let(:update_params) { 
        { 
          id: fc.id,
          fund_code: 
          { 
            title: 'New Title', 
            description: 'New Description',
            external_user: false
          }
        } 
      }

      before do 
        allow(controller).to receive(:require_permissions) { true }
      end

      it 'successfully updates attributes' do
        patch :update, params: update_params
        fc.reload
        expect(fc.title).to eq('New Title')
        expect(fc.description).to eq('New Description')
      end
    end

    context 'with updated members' do
      let(:manager) { User.create(email: 'manager@email.com', password: 'password')}
      let(:member1) { User.create(email: 'member1@email.com', password: 'password')}
      let(:member2) { User.create(email: 'member2@email.com', password: 'password')}
      let(:update_params) { 
        { 
          id: fc.id,
          fund_code: 
          { 
            external_user: false,
            managers: manager.user_key.to_s, 
            standard_members: "#{member1.user_key}, #{member2.user_key}" 
          }
        } 
      }

      before do 
        allow(controller).to receive(:require_permissions) { true }
      end

      it 'successfully updates attributes' do
        patch :update, params: update_params
        fc.reload
        expect(fc.managers).to match_array([manager])
        expect(fc.standard_members).to match_array([member1, member2])
      end
    end

    context 'when user is not authorized to read admin dashboard' do
      let(:update_params) { 
        { 
          id: fc.id,
          fund_code: 
          { 
            title: 'New Title', 
            description: 'New Description',
            external_user: false
          }
        } 
      }

      it 'does not successfully update attributes' do
        patch :update, params: update_params
        fc.reload
        expect(fc.title).to_not eq('New Title')
        expect(fc.description).to_not eq('New Description')
      end 
    end
  end

  describe 'DELETE #delete' do
    let(:user) { User.create(email: 'user@email.com', password: 'password')}
    let(:fc) { FundCode.new(title: 'Test Title', description: 'Test Description', chargeable: false, user: user)}
    let(:delete_params) { { id: fc.id } }

    before do 
      allow(user).to receive(:admin?) { true }
      allow(controller).to receive(:current_user) { user }
      allow(controller).to receive(:require_permissions) { true }
      fc.save!
    end

    it 'deletes fund code' do
      expect{
        process :delete, method: :delete, params: delete_params
      }.to change{FundCode.count}.by(-1)
    end
  end
end