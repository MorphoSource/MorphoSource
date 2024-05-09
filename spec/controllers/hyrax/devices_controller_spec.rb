# Generated via
#  `rails generate hyrax:work Device`
require 'rails_helper'

RSpec.describe Hyrax::DevicesController do
  let(:main_app) { Rails.application.routes.url_helpers }

  it "should have curation_concern_type ::Device" do
    expect(Hyrax::DevicesController.curation_concern_type).to be(::Device)
  end
  it "should have show_presenter Hyrax::DevicePresenter" do
  	expect(Hyrax::DevicesController.show_presenter).to be(Hyrax::DevicePresenter)
  end

  describe 'device access' do
    let(:depositor)         { User.create(email: 'depositor@email.com', password: 'password') }
    let!(:collection_type)  { Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Organizations::SETTINGS)}
        let!(:organization) { FactoryBot.create(:organization_collection, depositor: depositor.ms_id) }
    let!(:device)           { FactoryBot.create(:device, title: ['device title'], creator: ['device creator'], depositor: depositor.ms_id) }

    before do
      sign_in user
    end

    # TODO: Remove admin-only restriction tests when organization collections go live on production
    describe 'temporary admin-only restriction' do
      let(:params)      { { id: device.id } }
      let(:new_params)  { { organization_id: organization.id, device: { title: 'title', creator: 'creator' } } }

      context 'user is an admin' do
        let(:user) { FactoryBot.create(:admin) }

        it 'renders the view' do
          get :new, params: {}
          expect(response.status).to eq(200)
          get :show, params: params
          expect(response.status).to eq(200)
        end

        it 'creates the device' do
          post :create, params: new_params
          expect(response.status).to eq(302)
          expect(response).to redirect_to(main_app.organization_devices_path(organization, locale: 'en'))
        end
      end

      context 'user is a contributor' do
        let(:user)  { FactoryBot.create(:contributor) }

        before do
          organization.managers << user
        end

        it 'renders the view' do
          get :new, params: { organization_id: organization.id }
          expect(response.status).to eq(200)
        end

        it 'does not render the view' do
          get :show, params: params
          expect(response.status).to eq(302)
          expect(response).to redirect_to(root_path)
        end

        it 'creates the device' do
          post :create, params: new_params
          expect(response.status).to eq(302)
          expect(response).to redirect_to(main_app.organization_devices_path(organization, locale: 'en'))
        end
      end
    end

    # expected behavior once admin restriction is removed
    describe 'user is a contributor' do
      let(:user)  { FactoryBot.create(:contributor) }

      before do
        allow(controller).to receive(:authorize_admin).and_return(true)
      end

      context 'user creates a device from an organization page' do
        let(:params)  { { organization_id: organization.id, device: { title: 'title', creator: 'creator' } } }

        before do
          organization.create_collection_groups
          Morphosource::Collections::PermissionsCreateService.create_default(collection: organization)
        end

        context 'user creates a device within an organization' do
          context 'user is an org manager or editor' do
            context 'user is a manager' do
              before do
                organization.managers << user
              end
              it 'creates the device' do
                post :create, params: params
                expect(response.status).to eq(302)
                expect(response).to redirect_to(main_app.organization_devices_path(organization, locale: 'en'))
              end
            end
            context 'user is an editor' do
              before do
                organization.editors << user
              end
              it 'creates the device' do
                post :create, params: params
                expect(response.status).to eq(302)
                expect(response).to redirect_to(main_app.organization_devices_path(organization, locale: 'en'))
              end
            end
          end
          context 'user is not an org manager or editor' do
            context 'user is a depositor' do
              before do
                organization.depositors << user
              end
              it 'does not create the device' do
                post :create, params: params
                expect(response.status).to eq(302)
                expect(response).to redirect_to(root_path)
              end
            end
            context 'user is a downloader' do
              before do
                organization.downloaders << user
              end
              it 'does not create the device' do
                post :create, params: params
                expect(response.status).to eq(302)
                expect(response).to redirect_to(root_path)
              end
            end
            context 'user is a viewer' do
              before do
                organization.viewers << user
              end
              it 'does not create the device' do
                post :create, params: params
                expect(response.status).to eq(302)
                expect(response).to redirect_to(root_path)
              end
            end
          end
        end
        context 'user tries to create a device without an organization id' do
          let(:params)  { { device: { title: 'title', creator: 'creator' } } }
          context 'user is an org manager or editor' do
            context 'user is a manager' do
              before do
                organization.managers << user
              end
              it 'does not create the device' do
                post :create, params: params
                expect(response.status).to eq(302)
                expect(response).to redirect_to(root_path)
              end
            end
            context 'user is an editor' do
              before do
                organization.editors << user
              end
              it 'does not create the device' do
                post :create, params: params
                expect(response.status).to eq(302)
                expect(response).to redirect_to(root_path)
              end
            end
          end
          context 'user is not an org manager or editor' do
            context 'user is a depositor' do
              before do
                organization.depositors << user
              end
              it 'does not create the device' do
                post :create, params: params
                expect(response.status).to eq(302)
                expect(response).to redirect_to(root_path)
              end
            end
            context 'user is a downloader' do
              before do
                organization.downloaders << user
              end
              it 'does not create the device' do
                post :create, params: params
                expect(response.status).to eq(302)
                expect(response).to redirect_to(root_path)
              end
            end
            context 'user is a viewer' do
              before do
                organization.viewers << user
              end
              it 'does not create the device' do
                post :create, params: params
                expect(response.status).to eq(302)
                expect(response).to redirect_to(root_path)
              end
            end
          end
        end
      end
    end

    describe 'user is an admin' do
      let(:user)    { FactoryBot.create(:admin) }
      let(:params)  { { device: { title: 'title', creator: 'creator' } } }
      context 'admin can create a device without an organization' do
        it 'creates the device' do
          post :create, params: params
          expect(response.status).to eq(302)
          expect(response).to redirect_to(main_app.hyrax_device_path(Device.last, locale: 'en'))
        end
      end
    end
  end
end
