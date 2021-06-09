require 'rails_helper'
include ActionDispatch::TestProcess
include Warden::Test::Helpers

RSpec.describe Morphosource::My::WorksController, type: :controller do
  let(:user)    { User.create(email: 'user@email.com', password: 'password') }
  let(:admins)  { Role.create(name: 'admin') }

  describe 'ms_default_facet_limit' do
    before do
      sign_in user
    end
    context 'user is an admin' do
      before do
        admins.users += [user]
        user.save!
      end
      it 'sets the ms default facet limit to 15' do
        expect(subject.ms_default_facet_limit).to eq(15)
      end
    end
    context 'user is not an admin' do
      before do
      end
      it 'sets the ms default facet limit to nil' do
        expect(subject.ms_default_facet_limit).to eq(nil)
      end
    end
  end
end
