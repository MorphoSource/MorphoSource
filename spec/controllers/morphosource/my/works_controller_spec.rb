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

  describe 'index' do
    before do
      Rails.application.routes.draw { get '/dashboard/my/works' => 'morphosource/my/works#index' }
      allow(controller).to receive(:add_breadcrumbs).and_return(nil)
      sign_in user
    end
    describe 'facet limits' do
      context 'user is an admin' do
        before do
          admins.users += [user]
          user.save!
          get :index
        end
        it 'sets the individual facet limits to 15' do
          facet_limits = subject.instance_variable_get(:@blacklight_config).facet_fields.each_with_object([]){|(k,v),limits| limits << v.limit}
          expect(facet_limits.uniq).to match_array([15])
        end
      end
    end

    context 'user is not an admin' do
      before do
        get :index
      end
      it 'sets the facet limit to nil' do
        facet_limits = subject.instance_variable_get(:@blacklight_config).facet_fields.each_with_object([]){|(k,v),limits| limits << v.limit}
        expect(facet_limits.uniq).to match_array([nil])
      end
    end
  end
end
