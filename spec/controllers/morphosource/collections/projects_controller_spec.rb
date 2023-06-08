require 'rails_helper'
require 'spec_helper'

include ActionDispatch::TestProcess

RSpec.describe Morphosource::Collections::ProjectsController, type: :controller do

  let(:user)                    { User.create(email: 'user@email.com', password: 'password') }
  let(:depositor) { User.create(email: 'depositor@email.com', password: 'password') }
  let(:project)                 { Collection.create(title: ['project'], collection_type_gid: project_collection_type.gid, depositor: depositor.ms_id) }

  before do
    project.create_collection_groups
    Morphosource::Collections::PermissionsCreateService.create_default(collection: project)
  end

  describe "search_builder_class" do
    it{ expect(subject.search_builder_class).to eq(Morphosource::Collections::MediaSearchBuilder) }
  end

  describe "#show" do
    describe 'access' do
      context 'project is public' do
        before do
          project.visibility = 'open'
          project.save!
          get :show, params: { id: project.id }
        end
        it { expect(response.status).to eq(200) }
      end
      context 'project is private' do
        context 'user is not signed in' do
          before do
            get :show, params: { id: project.id }
          end
          it 'is unauthorized' do
            expect(response).to redirect_to root_path
            expect(flash[:alert]).to eq('You are not authorized to access this collection.')
          end
        end
        context 'user is signed in' do
          context 'user does not have access' do
            before do
              sign_in user
              get :show, params: { id: project.id }
            end
            it 'is unauthorized' do
              expect(response).to redirect_to root_path
              expect(flash[:alert]).to eq('You are not authorized to access this collection.')
            end
          end
          context 'user has access' do
            before do
              project.read_users += [user.ms_id]
              project.save
              sign_in user
              get :show, params: { id: project.id }
            end
            it { expect(response.status).to eq(200) }
          end
        end
      end
    end

    describe 'temporary link access' do
      let(:main_app) { Rails.application.routes.url_helpers }

      describe 'via URL' do
        let(:temporary_link) { create(:temporary_collection_access_link, user: user, collection_id: project.id )}

        context 'user is not logged in but has a temporary access URL' do
          it 'user is authorized with temp link flash msg' do
            get :show, params: { id: project.id, token: temporary_link.token }
            expect(response.status).to eq(200)
            expect(response.flash[:notice]).to eq(I18n.t('morphosource.collections.view.temporary_access', collection_type: project))
          end
        end

        context 'user is logged in, has temporary access URL, but already has access to project' do
          before do
            sign_in user
            project.editors_group.users << user
            project.editors_group.save
            project.save
          end

          it 'user is authorized with temp link flash msg' do
            get :show, params: { id: project.id, token: temporary_link.token }
            expect(response.status).to eq(200)
            expect(response.flash[:notice]).to eq(I18n.t('morphosource.collections.view.temporary_access', collection_type: project))
          end
        end

        context 'user is logged in, has temporary access URL, and does not have access to media' do
          before do
            sign_in user
          end

          it 'user is authorized with temp link flash msg' do
            get :show, params: { id: project.id, token: temporary_link.token }
            expect(response.status).to eq(200)
            expect(response.flash[:notice]).to eq(I18n.t('morphosource.collections.view.temporary_access', collection_type: project))
          end
        end

        context 'when temporary link URL has been revoked' do
          it 'user is redirected to sign-in page without authorization' do
            temporary_link.destroy!
            get :show, params: { id: project.id, token: temporary_link.token }
            expect(response.status).to eq(302)
            expect(response).to redirect_to main_app.new_user_session_path(locale: 'en')
          end
        end
      end

      describe 'via cookie' do
        let(:temporary_link) { create(:temporary_collection_access_link, user: user, collection_id: project.id )}
        let(:cookie_jar) { ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar }
        let(:main_app) { Rails.application.routes.url_helpers }

        before do
          allow(subject).to receive(:cookies).and_return(cookie_jar)
        end

        context 'user is not logged in but has a temporary access cookie' do
          it 'user is authorized with temp link flash msg' do
            cookie_jar.encrypted["ta_#{temporary_link.collection_id}"] = {
              value: temporary_link.token,
              expires: temporary_link.expires_at
            }

            get :show, params: { id: project.id }
            expect(response.status).to eq(200)
            expect(response.flash[:notice]).to eq(I18n.t('morphosource.collections.view.temporary_access', collection_type: project))
          end
        end

        context 'user is logged in, has temporary access cookie, but already has access to project' do
          before do
            sign_in user
            project.editors_group.users << user
            project.editors_group.save
            project.save
          end

          it 'user is authorized without temp link flash msg' do
            cookie_jar.encrypted["ta_#{temporary_link.collection_id}"] = {
              value: temporary_link.token,
              expires: temporary_link.expires_at
            }

            get :show, params: { id: project.id }
            expect(response.status).to eq(200)
            expect(response.flash[:notice]).to eq(nil)
          end
        end

        context 'user is logged in, has temporary access cookie, and does not have access to project' do
          before do
            sign_in user
          end

          it 'user is authorized with temp link flash msg' do
            cookie_jar.encrypted["ta_#{temporary_link.collection_id}"] = {
              value: temporary_link.token,
              expires: temporary_link.expires_at
            }

            get :show, params: { id: project.id }
            expect(response.status).to eq(200)
            expect(response.flash[:notice]).to eq(I18n.t('morphosource.collections.view.temporary_access', collection_type: project))
          end
        end

        context 'when temporary link cookie has been revoked' do
          it 'user is redirected to sign-in page without authorization' do
            temporary_link.destroy!

            cookie_jar.encrypted["ta_#{temporary_link.collection_id}"] = {
              value: temporary_link.token,
              expires: temporary_link.expires_at
            }

            get :show, params: { id: project.id }
            expect(response.status).to eq(302)
            expect(response).to redirect_to main_app.root_path(locale: 'en')
            expect(response.flash[:alert]).to eq('You are not authorized to access this collection.')
          end
        end
      end
    end
  end

  describe 'tab' do
    it {expect(subject.send(:tab)).to eq(:media) }
  end

  describe 'presenter_class' do
    it {expect(subject.presenter_class).to eq(Morphosource::Collections::ProjectPresenter) }
  end

  # helpers/morphosource/my/works_helper
  describe '#search_action_for_dashboard' do
    let(:main_app)    { Rails.application.routes.url_helpers }
    let(:params)      { { controller: controller.controller_path } }
    let(:collection)  { double('collection', id: 'abc')}
    subject           { controller.view_context }

    before do
      allow(subject).to receive(:params).and_return(params)
      subject.instance_variable_set(:@collection, collection)
    end

    it { expect(subject.search_action_for_dashboard).to eq(main_app.project_path(id: collection.id, locale: 'en')) }
  end
end
