require 'rails_helper'

RSpec.describe CollectionRolesController, :type => :controller do

  describe 'update_notice' do
    let(:params)      {  { collection_roles: { access: 'manager' } } }
    let(:collection)  { double('collection', title: ['collection title']) }

    before do
      subject.instance_variable_set(:@collection, collection)
    end

    context 'status is success' do
      let(:status)  { 'success' }
      it 'has the correct success message' do
        subject.send(:update_notice, status)
        expect(flash[:notice]).to eq("The collection's sharing options have been updated.")
      end
    end
    context 'status is fail' do
      let(:status)  { 'fail' }
      it 'has the correct fail message' do
        subject.send(:update_notice, status)
        expect(flash[:error]).to eq({:error=>"Invalid update option for permission template."})
      end
    end
    context 'status is user_status' do
      let(:status)      { 'user_status' }
      before do
        subject.instance_variable_set(:@non_contributors, ['user1@email.com', 'user2@email.com'])
        subject.instance_variable_set(:@collection, collection)
        allow(subject).to receive(:params).and_return(params)
      end
      context 'collection is a list' do
        before do
          allow(collection).to receive(:list?).and_return(true)
        end
        it 'has the correct user status message' do
          subject.send(:update_notice, status)
          expect(flash[:error]).to eq("Users (user1@email.com, user2@email.com) can't be added to the manager role because they do not have contributor status. Either add the users to a membership role that does not require contributor status (viewer) or have the users request contributor status.")
        end
      end
      context 'collection is not a list' do
        before do
          allow(collection).to receive(:list?).and_return(false)
        end
        it 'has the correct user status message' do
          subject.send(:update_notice, status)
          expect(flash[:error]).to eq("Users (user1@email.com, user2@email.com) can't be added to the manager role because they do not have contributor status. Either add the users to a membership role that does not require contributor status (downloader, viewer) or have the users request contributor status.")
        end
      end
    end
    context 'status is duplicate' do
      let(:status)  { 'duplicate' }
      let(:user)    { double('user', name: 'user_name') }
      before do
        subject.instance_variable_set(:@user, user)
      end
      it 'has the correct duplicate message' do
        subject.send(:update_notice, status)
        expect(flash[:error]).to eq("user_name is already a member of collection title")
      end
    end
  end
end