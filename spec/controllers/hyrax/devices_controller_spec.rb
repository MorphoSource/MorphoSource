# Generated via
#  `rails generate hyrax:work Device`
require 'rails_helper'

RSpec.describe Hyrax::DevicesController do
  let(:main_app) { Rails.application.routes.url_helpers }

  it "should have curation_concern_type ::Device" do
    expect(Hyrax::DevicesController.curation_concern_type).to be(::DeviceResource)
  end
  it "should have show_presenter Hyrax::DevicePresenter" do
  	expect(Hyrax::DevicesController.show_presenter).to be(Hyrax::DevicePresenter)
  end

  describe 'device access' do
    let(:depositor)         { User.create(email: 'depositor@email.com', password: 'password') }
    let!(:collection_type)  { Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Organizations::SETTINGS)}
    let!(:organization)     { FactoryBot.create(:organization_collection, depositor: depositor.ms_id) }
    let!(:device)           { FactoryBot.valkyrie_create(:device_resource, title: ['device title'], creator: ['device creator'], depositor: depositor.ms_id) }

    before do
      sign_in user
    end

    # expected behavior once admin restriction is removed
    describe 'user is a contributor' do
      let(:user)  { FactoryBot.create(:contributor) }

      before do
        allow(controller).to receive(:authorize_admin).and_return(true)
      end

      context 'user creates a device from an organization page' do
        let(:params)  { { organization_id: organization.id, device_resource: { title: ['title'], creator: ['creator'], modality: ['XRay'] } } }
        let!(:organization_solr_doc) { FactoryBot.create(:organization_collection_document, id: organization.id, title_tesim: organization.title) }

        before do
          organization.create_collection_groups
          Morphosource::Collections::PermissionsCreateService.create_default(collection: organization)
        end

        context 'user creates a device within an organization' do
          context 'user is an org manager or editor' do
            context 'user is a manager' do
              before do
                organization.managers << user
                organization.managers_group.save
                allow(user).to receive(:groups).and_return(["#{organization.id}_managers"])
                allow(controller).to receive(:authorize!).with(:create, DeviceResource).and_return(true)
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
                organization.editors_group.save
                allow(user).to receive(:groups).and_return(["#{organization.id}_editors"])
                allow(controller).to receive(:authorize!).with(:create, DeviceResource).and_return(true)
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
          let(:params)  { { device_resource: { title: ['title'], creator: ['creator'], modality: ['XRay'] } } }
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
      let(:params)  { { device_resource: { title: ['title'], creator: ['creator'], modality: ['XRay'] } } }
      context 'admin can create a device without an organization' do
        it 'creates the device' do
          post :create, params: params
          expect(response.status).to eq(302)
          expect(response).to redirect_to(main_app.hyrax_device_path(controller.curation_concern, locale: 'en'))
        end
      end

      context 'admin creates from an organization page' do
        let(:params) do
          {
            from_org_id: organization.id,
            device_resource: { title: ['title'], creator: ['creator'], modality: ['XRay'] }
          }
        end

        it 'redirects back to the organization devices list' do
          post :create, params: params
          expect(response.status).to eq(302)
          expect(response).to redirect_to(main_app.organization_devices_path(organization.id, locale: 'en'))
        end
      end

      describe 'destroying a device resource' do
        let(:device_id) { Valkyrie::ID.new('device-id-1') }
        let(:device_resource) do
          double(
            'DeviceResource',
            id: device_id,
            ark: ['ark:/99999/fk4/123'],
            title: ['Device A']
          )
        end
        let(:transaction_result) { Dry::Monads::Success(device_resource) }
        let(:publisher) { Hyrax.publisher }

        before do
          allow(controller).to receive(:curation_concern).and_return(device_resource)
          allow(controller).to receive(:after_destroy_response)
          allow(device_resource).to receive(:is_a?).with(ActiveFedora::Base).and_return(false)
          allow(controller).to receive(:transactions)
            .and_return('device_work_resource.destroy' => instance_double('Transaction', with_step_args: instance_double('Callable', call: transaction_result)))
          allow(publisher).to receive(:publish)
        end

        it 'publishes object.deleted with deleted_ark payload' do
          controller.destroy

          expect(publisher).to have_received(:publish).with(
            'object.deleted',
            hash_including(
              object: device_resource,
              deleted_ark: 'ark:/99999/fk4/123'
            )
          )
        end
      end
    end
  end

end
