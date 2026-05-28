# Generated via
#  `rails generate hyrax:work Media`
require 'rails_helper'
include ActionDispatch::TestProcess
include Warden::Test::Helpers

RSpec.describe Hyrax::MediaController, type: :controller do
  routes          { Rails.application.routes }
  let(:main_app)  { Rails.application.routes.url_helpers }
  let(:hyrax)     { Hyrax::Engine.routes.url_helpers }

  let(:work_solr_document) do
    SolrDocument.new(id: '999',
                     title_tesim: ['My Title'],
                     creator_tesim: ['Doe, John', 'Doe, Jane'],
                     date_modified_dtsi: '2011-04-01',
                     has_model_ssim: ['Media'],
                     depositor_tesim: depositor.user_key,
                     description_tesim: ['Lorem ipsum lorem ipsum.'],
                     keyword_tesim: ['bacon', 'sausage', 'eggs'],
                     rights_statement_tesim: ['http://example.org/rs/1'],
                     date_created_tesim: ['1984-01-02'])
  end

  let(:depositor) do
    FactoryBot.create(:user)
  end

  let(:ability) { double }

  let(:test_presenter) do
    Hyrax::MediaPresenter.new(work_solr_document, ability, request)
  end

  let(:public)      { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  let(:private)     { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
  let(:embargo)     { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO }
  let(:lease)       { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_LEASE }

  describe "search_builder_class" do
    it "is Morphosource::WorkSearchBuilder" do
      expect(subject.search_builder_class).to be(Morphosource::WorkSearchBuilder)
    end
  end

  describe 'GET #showcase' do
    let!(:work)         { Media.create(title: ['test title'], visibility: private, fileset_visibility: [""], fileset_accessibility: ["private"]) }
    let(:access_group)  { Role.create(name: 'access_group') }
    let(:user)          { User.create(email: 'user@email.com', password: 'password') }

    describe 'user ability to view' do
      before do
        access_group.users << user
        access_group.save
        sign_in user
      end

      context 'work is private' do
        context 'user does not have access' do
          it 'redirects to site root with not found flash' do
            get :showcase, params: { id: work.id }
            expect(response.status).to eq(302)
          end
        end
        context 'user has edit access' do
          context 'through a group' do
            before do
              work.edit_groups += [access_group]
              work.save
            end
            it 'is authorized' do
              get :showcase, params: { id: work.id }
              expect(response.status).to eq(200)
            end
          end
          context 'as a user' do
            before do
              work.edit_users += [user]
              work.save
            end
            it 'is authorized' do
              get :showcase, params: { id: work.id }
              expect(response.status).to eq(200)
            end
          end
        end
        context 'user has download access' do
          context 'through a group' do
            before do
              work.download_groups += [access_group]
              work.save
            end
            it 'is authorized' do
              get :showcase, params: { id: work.id }
              expect(response.status).to eq(200)
            end
          end
          context 'as a user' do
            before do
              work.download_users += [user]
              work.save
            end
            it 'is authorized' do
              get :showcase, params: { id: work.id }
              expect(response.status).to eq(200)
            end
          end
        end
        context 'user has read access' do
          context 'through a group' do
            before do
              work.read_groups += [access_group]
              work.save
            end
            it 'is authorized' do
              get :showcase, params: { id: work.id }
              expect(response.status).to eq(200)
            end
          end
          context 'as a user' do
            before do
              work.read_users += [user]
              work.save
            end
            it 'is authorized' do
              get :showcase, params: { id: work.id }
              expect(response.status).to eq(200)
            end
          end
        end
      end
    end

    describe 'user is not logged in' do
      context 'media is private' do
        it 'redirects site root with not found flash' do
          get :showcase, params: { id: work.id }
          expect(response.status).to eq(302)
        end
      end
      context 'media is public' do
        let(:public_media) { Media.create(title: ['public media'], visibility: 'open') }
        it 'is authorized' do
          get :showcase, params: { id: public_media.id }
          expect(response.status).to eq(200)
        end
      end
    end

    describe 'temporary link access' do
      let(:main_app) { Rails.application.routes.url_helpers }

      describe 'via URL' do
        let(:temporary_link) { create(:temporary_media_access_link, user: user, media_id: work.id )}

        context 'user is not logged in but has a temporary access URL' do
          it 'user is authorized with temp link flash msg' do
            get :showcase, params: { id: work.id, token: temporary_link.token }
            expect(response.status).to eq(200)
            expect(response.flash[:notice]).to eq(I18n.t('morphosource.media.view.temporary_access'))
          end
        end

        context 'user is logged in, has temporary access URL, but already has access to media' do
          before do
            sign_in user
            work.read_users += [user]
            work.save
          end

          it 'user is authorized with temp link flash msg' do
            get :showcase, params: { id: work.id, token: temporary_link.token }
            expect(response.status).to eq(200)
            expect(response.flash[:notice]).to eq(I18n.t('morphosource.media.view.temporary_access'))
          end
        end

        context 'user is logged in, has temporary access URL, and does not have access to media' do
          before do
            sign_in user
          end

          it 'user is authorized with temp link flash msg' do
            get :showcase, params: { id: work.id, token: temporary_link.token }
            expect(response.status).to eq(200)
            expect(response.flash[:notice]).to eq(I18n.t('morphosource.media.view.temporary_access'))
          end
        end

        context 'when temporary link URL has been revoked' do

          it 'user is redirected to site root with not found flash without authorization' do
            temporary_link.destroy!
            get :showcase, params: { id: work.id, token: temporary_link.token }
            expect(response.status).to eq(302)
            expect(response).to redirect_to main_app.root_path(locale: 'en')
          end
        end
      end

      describe 'via cookie' do
        let(:cookie_jar) { ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar }
        let(:main_app) { Rails.application.routes.url_helpers }

        before do
          allow(subject).to receive(:cookies).and_return(cookie_jar)
        end

        describe 'for individual media access' do
          let(:temporary_link) { create(:temporary_media_access_link, user: user, media_id: work.id )}

          context 'user is not logged in but has a temporary access cookie' do
            it 'user is authorized with temp link flash msg' do
              cookie_jar.encrypted["ta_#{temporary_link.media_id}"] = {
                value: temporary_link.token,
                expires: temporary_link.expires_at
              }

              get :showcase, params: { id: work.id }
              expect(response.status).to eq(200)
              expect(response.flash[:notice]).to eq(I18n.t('morphosource.media.view.temporary_access'))
            end
          end

          context 'user is logged in, has temporary access cookie, but already has access to media' do
            before do
              sign_in user
              work.read_users += [user]
              work.save
            end

            it 'user is authorized without temp link flash msg' do
              cookie_jar.encrypted["ta_#{temporary_link.media_id}"] = {
                value: temporary_link.token,
                expires: temporary_link.expires_at
              }

              get :showcase, params: { id: work.id }
              expect(response.status).to eq(200)
              expect(response.flash[:notice]).to eq('')
            end
          end

          context 'user is logged in, has temporary access cookie, and does not have access to media' do
            before do
              sign_in user
            end

            it 'user is authorized with temp link flash msg' do
              cookie_jar.encrypted["ta_#{temporary_link.media_id}"] = {
                value: temporary_link.token,
                expires: temporary_link.expires_at
              }

              get :showcase, params: { id: work.id }
              expect(response.status).to eq(200)
              expect(response.flash[:notice]).to eq(I18n.t('morphosource.media.view.temporary_access'))
            end
          end

          context 'when temporary link cookie has been revoked' do
            it 'user is redirected to site root with not found flash without authorization' do
              temporary_link.destroy!

              cookie_jar.encrypted["ta_#{temporary_link.media_id}"] = {
                value: temporary_link.token,
                expires: temporary_link.expires_at
              }

              get :showcase, params: { id: work.id }
              expect(response.status).to eq(302)
              expect(response).to redirect_to main_app.root_path(locale: 'en')
            end
          end
        end

        describe 'for access to media through project' do
          let(:temporary_link) { create(:temporary_collection_access_link, user: user, collection_id: '123456789' )}

          before do
            allow_any_instance_of(Media).to receive(:member_of_collection_ids).and_return(['123456789'])
          end

          context 'user is not logged in but has a temporary access cookie' do
            it 'user is authorized' do
              cookie_jar.encrypted["ta_#{temporary_link.collection_id}"] = {
                value: temporary_link.token,
                expires: temporary_link.expires_at
              }

              get :showcase, params: { id: work.id }
              expect(response.status).to eq(200)
            end
          end

          context 'user is logged in, has temporary access cookie, and does not have access to media' do
            before do
              sign_in user
            end

            it 'user is authorized with temp link flash msg' do
              cookie_jar.encrypted["ta_#{temporary_link.collection_id}"] = {
                value: temporary_link.token,
                expires: temporary_link.expires_at
              }

              get :showcase, params: { id: work.id }
              expect(response.status).to eq(200)
            end
          end

          context 'when temporary link cookie has been revoked' do
            it 'user is redirected to to site root with not found flash without authorization' do
              temporary_link.destroy!

              cookie_jar.encrypted["ta_#{temporary_link.collection_id}"] = {
                value: temporary_link.token,
                expires: temporary_link.expires_at
              }

              get :showcase, params: { id: work.id }
              expect(response.status).to eq(302)
              expect(response).to redirect_to main_app.root_path(locale: 'en')
            end
          end
        end
      end
    end
  end

  describe "#valid_file_formats" do
    let(:work)        { Media.new(title: ["Test Media Work"]) }
    let(:user)        { FactoryBot.create(:user) }
    let(:file_path1)  { fixture_path + '/images/duke.png' }
    let(:file_path2)  { fixture_path + '/images/ms.jpg' }
    let(:file_path3)  { fixture_path + '/images/ms_2.jpg' }
    let(:file_path4)  { fixture_path + '/ms.zip'}
    let(:local_file1) { File.open(file_path1) }
    let(:local_file2) { File.open(file_path2) }
    let(:local_file3) { File.open(file_path3) }
    let(:local_file4) { File.open(file_path4) }

    # New uploads
    let(:upload1)     { Hyrax::UploadedFile.create(user_id: user.id, file: local_file1) }
    let(:upload2)     { Hyrax::UploadedFile.create(user_id: user.id, file: local_file2) }
    let(:uploaded_file_ids) { [upload1.id, upload2.id] }

    # Previous uploads
    let(:file_set_1)   { FileSet.new }
    let(:file_set_3)   { FileSet.new }
    let(:file_set_4)   { FileSet.new }

    before do
      allow(subject).to receive(:curation_concern).and_return(work)
      Hydra::Works::AddFileToFileSet.call(file_set_1, local_file1, :original_file, versioning: true)
      Hydra::Works::AddFileToFileSet.call(file_set_3, local_file3, :original_file, versioning: true)
      Hydra::Works::AddFileToFileSet.call(file_set_4, local_file4, :original_file, versioning: true)
    end

    context "Previously uploaded files and new uploads are correct for the selected media type" do
      before do
        allow(subject).to receive(:attributes_for_actor).and_return( { "media_type"=>["Image"], "uploaded_files"=>uploaded_file_ids} )
        work.ordered_members << file_set_1 << file_set_3
      end

      it "returns true" do
        expect(subject.send(:file_formats_valid?)).to be(true)
      end

      it "has no base errors" do
        subject.send(:file_formats_valid?)
        expect(subject.curation_concern.errors[:base]).to match_array( [] )
      end
    end

    context "Previously uploaded files and new uploads are incorrect for the selected media type" do
      before do
        allow(subject).to receive(:attributes_for_actor).and_return( { "media_type" => ["Video"], "uploaded_files" => uploaded_file_ids} )
        work.ordered_members << file_set_1 << file_set_3
      end

      it "returns false" do
        expect(subject.send(:file_formats_valid?)).to be(false)
      end

      it "adds all the filenames to a base error" do
        subject.send(:file_formats_valid?)
        expect(subject.curation_concern.errors[:base][0]).to include("duke.png","ms.jpg","ms_2.jpg")
      end
    end

    context "Previously uploaded files are correct and new uploads are incorrect for the selected media type" do
      before do
        allow(subject).to receive(:attributes_for_actor).and_return( { "media_type" => ["CTImageSeries"], "uploaded_files" => uploaded_file_ids} )
        work.ordered_members << file_set_4
      end

      it "returns false" do
        expect(subject.send(:file_formats_valid?)).to be(false)
      end

      it "adds the newly uploaded filenames to a base error" do
        subject.send(:file_formats_valid?)
        expect(subject.curation_concern.errors[:base][0]).to include("duke.png","ms.jpg")
      end
    end

    context "Previously uploaded files are incorrect and new uploads are correct for the selected media type" do
      before do
        allow(subject).to receive(:attributes_for_actor).and_return( { "media_type" => ["Image"], "uploaded_files" => uploaded_file_ids} )
        work.ordered_members << file_set_4
      end

      it "returns false" do
        expect(subject.send(:file_formats_valid?)).to be(false)
      end

      it "adds the previously uploaded filenames to a base error" do
        subject.send(:file_formats_valid?)
        expect(subject.curation_concern.errors[:base][0]).to include("ms.zip")
      end
    end
  end

  describe "#map_publication_status_to_visibility" do
    let(:work)        { Media.new(title: ["Test Media Work"]) }
    let(:file_set_1)  { FileSet.new }

    before do
      allow(subject).to receive(:curation_concern).and_return(work)
      work.ordered_members << file_set_1
      allow(subject).to receive(:params).and_return(params)
      subject.send(:save_publication_status)
      subject.send(:map_publication_status_to_visibility)
    end

    # allow for either "restricted" or "private" to represent private media
    context 'when no publication status is selected' do
      context 'media is private' do
        let(:params)  { {"media"=> {"visibility" => "restricted"}} }

        it 'sets params for private media' do
          expect(subject.params["media"]["visibility"]).to eq("restricted")
          expect(subject.params["media"]["fileset_accessibility"]).to match_array(["private"])
        end
      end
    end

    context 'when user selects "open" publication status' do
      let(:params)  { {"media"=> {"visibility" => public}} }

      it 'sets params for "open" publication status' do
        expect(subject.params["media"]["visibility"]).to eq("open")
        expect(subject.params["media"]["fileset_accessibility"]).to match_array(["open"])
      end
    end

    context 'when user selects "restricted_download" publication status' do
      let(:params)  { {"media"=> {"visibility" => "restricted_download"}} }

      it 'sets params for "restricted_download" publication status' do
        expect(subject.params["media"]["visibility"]).to eq("open")
        expect(subject.params["media"]["fileset_accessibility"]).to match_array(["restricted_download"])
      end
    end

    context 'when user selects "private" publication status' do
      let(:params)  { {"media"=> {"visibility" => "private"}} }

      it 'sets params for "private" publication status' do
        expect(subject.params["media"]["visibility"]).to eq("restricted")
        expect(subject.params["media"]["fileset_accessibility"]).to match_array(["private"])
      end
    end
  end

  describe '#check_for_published_doi' do
    let(:doi)        { nil }
    let(:old_status) { nil }
    let(:work)       { Media.new(title: ["Test Media Work"], doi: doi, fileset_accessibility: [old_status].compact) }

    before do
      allow(subject).to receive(:curation_concern).and_return(work)
      allow(subject).to receive(:params).and_return(params)
      subject.send(:save_publication_status)
    end

    context 'when media has no DOI' do
      let(:params) { { "media" => { "visibility" => "private" } } }

      it 'does not redirect' do
        subject.send(:check_for_published_doi)
        expect(response).not_to be_redirect
      end
    end

    context 'when media has a DOI' do
      let(:doi) { ["10.1234/test"] }

      context 'and was previously private' do
        let(:old_status) { "private" }

        context 'and new status is "private"' do
          let(:params) { { "media" => { "visibility" => "private" } } }

          it 'does not redirect (allowed to keep private)' do
            subject.send(:check_for_published_doi)
            expect(response).not_to be_redirect
          end
        end

        context 'and new status is "open"' do
          let(:params) { { "media" => { "visibility" => "open" } } }

          it 'does not redirect (allowed to publish)' do
            subject.send(:check_for_published_doi)
            expect(response).not_to be_redirect
          end
        end
      end

      context 'and was previously published' do
        let(:old_status) { "open" }

        context 'and new status is "open"' do
          let(:params) { { "media" => { "visibility" => "open" } } }

          it 'does not redirect' do
            subject.send(:check_for_published_doi)
            expect(response).not_to be_redirect
          end
        end

        context 'and new status is "restricted_download"' do
          let(:params) { { "media" => { "visibility" => "restricted_download" } } }

          it 'does not redirect' do
            subject.send(:check_for_published_doi)
            expect(response).not_to be_redirect
          end
        end

        context 'and new status is "private"' do
          let(:params) { ActionController::Parameters.new("id" => "test-media-id", "media" => { "visibility" => "private" }) }

          it 'redirects with an error flash' do
            allow(subject).to receive(:redirect_to)
            subject.send(:check_for_published_doi)
            expect(subject).to have_received(:redirect_to)
            expect(flash[:error]).to include("Visibility cannot be changed to private")
          end
        end

        context 'and new status is "restricted" (mapped to private)' do
          let(:params) { ActionController::Parameters.new("id" => "test-media-id", "media" => { "visibility" => "restricted" }) }

          it 'redirects with an error flash' do
            allow(subject).to receive(:redirect_to)
            subject.send(:check_for_published_doi)
            expect(subject).to have_received(:redirect_to)
            expect(flash[:error]).to include("Visibility cannot be changed to private")
          end
        end
      end
    end
  end

  describe '#check_for_published_doi as admin' do
    let(:doi)  { ["10.1234/test"] }
    let(:work) { Media.new(title: ["Test Media Work"], doi: doi, fileset_accessibility: ["open"]) }

    before do
      sign_in depositor
      allow(subject.current_user).to receive(:admin?).and_return(true)
      allow(subject).to receive(:curation_concern).and_return(work)
      allow(subject).to receive(:params).and_return(params)
      subject.send(:save_publication_status)
      subject.send(:check_for_published_doi)
    end

    context 'and new status is "private"' do
      let(:params) { { "media" => { "visibility" => "private" } } }

      it 'does not redirect' do
        expect(response).not_to be_redirect
      end
    end

    context 'and new status is "restricted" (mapped to private)' do
      let(:params) { { "media" => { "visibility" => "restricted" } } }

      it 'does not redirect' do
        expect(response).not_to be_redirect
      end
    end
  end

  describe '#strip_doi_protected_fields' do
    let(:doi)  { nil }
    let(:work) { Media.new(title: ["Test Media Work"], doi: doi) }
    let(:params) do
      ActionController::Parameters.new({
        "media" => {
          "title" => ["New Title"],
          "description" => ["Updated description"],
          "visibility" => "open",
          "permissions_attributes" => { "0" => { "access" => "read" } },
          "aleph_scene" => '{"annotations":[]}'
        }
      })
    end

    before do
      allow(subject).to receive(:curation_concern).and_return(work)
      allow(subject).to receive(:params).and_return(params)
    end

    context 'when media has no DOI' do
      it 'does not strip any params' do
        subject.send(:strip_doi_protected_fields)
        expect(params["media"].keys).to include("title", "description", "visibility", "permissions_attributes")
      end
    end

    context 'when media has a DOI' do
      let(:doi) { ["10.1234/test"] }

      context 'and user is admin' do
        before do
          sign_in depositor
          allow(subject.current_user).to receive(:admin?).and_return(true)
        end

        it 'does not strip any params' do
          subject.send(:strip_doi_protected_fields)
          expect(params["media"].keys).to include("title", "description", "visibility", "permissions_attributes")
        end
      end

      context 'and user is not admin' do
        before do
          sign_in depositor
          allow(subject.current_user).to receive(:admin?).and_return(false)
        end

        it 'strips metadata params' do
          subject.send(:strip_doi_protected_fields)
          expect(params["media"].keys).not_to include("title", "description")
        end

        it 'keeps allowed params' do
          subject.send(:strip_doi_protected_fields)
          expect(params["media"].keys).to include("visibility", "permissions_attributes")
        end

        it 'keeps aleph_scene so annotations can still be saved' do
          subject.send(:strip_doi_protected_fields)
          expect(params["media"].keys).to include("aleph_scene")
        end
      end
    end
  end

  describe "#file_formats_valid? for DOI media" do
    let(:doi)  { ["10.1234/test"] }
    let(:work) { Media.new(title: ["Test Media Work"], doi: doi) }

    before do
      allow(subject).to receive(:curation_concern).and_return(work)
      # attributes_for_actor has no media_type, simulating stripped params
      allow(subject).to receive(:attributes_for_actor).and_return({ "media_type" => nil })
      allow(subject).to receive(:params).and_return({ "commit" => "Save" })
      sign_in depositor
    end

    context 'when user is not admin' do
      before do
        allow(subject.current_user).to receive(:admin?).and_return(false)
      end

      it 'returns true without running file format validation' do
        expect(subject.send(:file_formats_valid?)).to be(true)
      end

      it 'does not add file format errors' do
        subject.send(:file_formats_valid?)
        expect(work.errors[:base]).to be_empty
      end
    end

    context 'when user is admin' do
      before do
        allow(subject.current_user).to receive(:admin?).and_return(true)
        allow(subject).to receive(:attributes_for_actor).and_return({ "media_type" => ["Image"] })
      end

      it 'runs file format validation normally' do
        expect(subject.send(:file_formats_valid?)).to be(true)
      end
    end
  end

  describe '#set_doi_edit_flash' do
    let(:doi)       { nil }
    let(:published) { false }
    let(:presenter) { double('presenter', doi: doi, is_published?: published) }

    before do
      sign_in depositor
      subject.instance_variable_set(:@presenter, presenter)
    end

    context 'when media has no DOI' do
      it 'does not set a flash alert' do
        subject.send(:set_doi_edit_flash)
        expect(flash[:alert]).to be_nil
      end
    end

    context 'when media has a DOI' do
      let(:doi) { ['10.1234/test'] }

      context 'and user is admin' do
        before { allow(subject.current_user).to receive(:admin?).and_return(true) }

        it 'does not set a flash alert' do
          subject.send(:set_doi_edit_flash)
          expect(flash[:alert]).to be_nil
        end
      end

      context 'and user is not admin' do
        before { allow(subject.current_user).to receive(:admin?).and_return(false) }

        context 'and media is published' do
          let(:published) { true }

          it 'sets the doi_edit_warning alert' do
            subject.send(:set_doi_edit_flash)
            expect(flash[:alert]).to include('Metadata fields are locked')
          end
        end

        context 'and media is private' do
          let(:published) { false }

          it 'sets the doi_edit_warning_private alert' do
            subject.send(:set_doi_edit_flash)
            expect(flash[:alert]).to include('cannot be edited')
          end
        end
      end
    end
  end

  describe '#update' do
    let(:curation_concern)  { Media.create(title: ["title"]) }
    let(:actor)             { double(update: true) }

    before do
      sign_in depositor
      allow(Hyrax::CurationConcern).to receive(:actor).and_return(actor)
      allow(Media).to receive(:find).and_return(curation_concern)
      allow(controller).to receive(:authorize!).with(:update, curation_concern).and_return(true)
      allow(subject).to receive(:attributes_for_actor).and_return( { "media_type" => ["Image"]} )
    end

    context 'file formats are valid' do
      context 'actor update is successful' do
        it 'calls update_filesets' do
          expect(controller).to receive(:update_filesets)
          patch :update, params: { id: curation_concern.id, media: {visibility: "open"}, action: "update" }
        end
      end
    end
  end

  describe '#update_filesets' do
    let(:curation_concern)  { Media.create(title: ["title"]) }

    before do
      allow(controller).to receive(:curation_concern).and_return(curation_concern)
    end

    context 'publication status has changed' do
      before do
        allow(controller).to receive(:publication_status_changed?).and_return(true)
      end
      context 'permissions have changed' do
        before do
          allow(controller).to receive(:permissions_changed?).and_return(true)
        end
        it 'calls VisibilityCopyJob and InheritPermissionsJob' do
          expect(VisibilityCopyJob).to receive(:perform_later).with(curation_concern.id)
          expect(InheritPermissionsJob).to receive(:perform_later).with(curation_concern.id)
          controller.send(:update_filesets)
        end
      end
      context 'permissions have not changed' do
        before do
          allow(controller).to receive(:permissions_changed?).and_return(false)
        end
        it 'calls VisibilityCopyJob only' do
          expect(VisibilityCopyJob).to receive(:perform_later).with(curation_concern.id)
          expect(InheritPermissionsJob).not_to receive(:perform_later)
          controller.send(:update_filesets)
        end
      end
    end

    context 'publication status has not changed' do
      before do
        allow(controller).to receive(:publication_status_changed?).and_return(false)
      end
      context 'permissions have changed' do
        before do
          allow(controller).to receive(:permissions_changed?).and_return(true)
        end
        it 'calls InheritPermissionsJob only' do
          expect(VisibilityCopyJob).not_to receive(:perform_later)
          expect(InheritPermissionsJob).to receive(:perform_later).with(curation_concern.id)
          controller.send(:update_filesets)
        end
      end
      context 'permissions have not changed' do
        before do
          allow(controller).to receive(:permissions_changed?).and_return(false)
        end
        it 'does not call either job' do
          expect(VisibilityCopyJob).not_to receive(:perform_later)
          expect(InheritPermissionsJob).not_to receive(:perform_later)
          controller.send(:update_filesets)
        end
      end
    end
  end

  describe '#after_update_response' do
    let(:curation_concern) { Media.create(title: ["title"]) }
    let(:actor) { double(update: true) }

    let(:file_path1)  { fixture_path + '/images/duke.png' }
    let(:file_path2)  { fixture_path + '/images/ms.jpg' }
    let(:file_path3)  { fixture_path + '/images/ms_2.jpg' }
    let(:local_file1) { File.open(file_path1) }
    let(:local_file2) { File.open(file_path2) }
    let(:local_file3) { File.open(file_path3) }
    let(:file_set_1)  { FileSet.new(visibility: "open") }
    let(:file_set_2)  { FileSet.new(visibility: "open") }
    let(:file_set_3)  { FileSet.new(visibility: "open") }

    let(:fund_code1) { FundCode.new(title: 'Test Fund Code 1', user: depositor)}
    let(:fund_code2) { FundCode.new(title: 'Test Fund Code 2', user: depositor)}

    before do
      sign_in depositor
      allow(Hyrax::CurationConcern).to receive(:actor).and_return(actor)
      allow(Media).to receive(:find).and_return(curation_concern)
      allow(controller).to receive(:publication_status_changed?).and_return(false)
      allow(controller).to receive(:authorize!).with(:update, curation_concern).and_return(true)
      # allow(curation_concern).to receive(:file_sets).and_return(double(present?: true))
      Hydra::Works::AddFileToFileSet.call(file_set_1, local_file1, :original_file, versioning: true)
      Hydra::Works::AddFileToFileSet.call(file_set_2, local_file2, :original_file, versioning: true)
      Hydra::Works::AddFileToFileSet.call(file_set_3, local_file3, :original_file, versioning: true)
      curation_concern.ordered_members << file_set_1 << file_set_2 << file_set_3

      allow(subject).to receive(:attributes_for_actor).and_return( { "media_type" => ["Image"]} )

      fund_code1.save!
      fund_code2.save!
    end

    context 'standard update' do
      before do
        patch :update, params: { id: curation_concern, media: {visibility: "open"}, action: "update" }
      end

      it 'redirects to the work show page' do
        expect(response).to redirect_to main_app.hyrax_media_path(curation_concern, locale: 'en')
      end

      it 'displays a flash message' do
        expect(response.flash[:notice]).to eq(I18n.t("morphosource.media.alert.permissions_update"))
      end
    end

    context 'fund code setting and creation' do
      context 'media has no current fund code' do
        before do
          allow(subject.current_user).to receive(:admin?).and_return(true)
        end

        it 'admin user can successfully add new fund code' do
          patch :update, params: { id: curation_concern, media: {select_new_fund_code: fund_code1.id}, action: "update" }
          expect(curation_concern.fund_codes).to include(fund_code1)
        end
      end

      context 'media has already been associated to fund codes' do
        before do
          allow(subject.current_user).to receive(:admin?).and_return(true)
          patch :update, params: { id: curation_concern, media: {select_new_fund_code: fund_code1.id}, action: "update" }
          patch :update, params: { id: curation_concern, media: {select_new_fund_code: fund_code2.id}, action: "update" }
        end

        it 'second fund code associated is active' do
          expect(curation_concern.active_fund_code_association.fund_code_id).to eq(fund_code2.id)
        end

        it 'admin user can activate another fund code' do
          inactive_fund_code = curation_concern.fund_code_associations.where(active: false).first
          patch :update, params: { id: curation_concern, media: {select_fund_code: inactive_fund_code.id}, action: "update" }
          expect(curation_concern.active_fund_code_association.fund_code_id).to eq(fund_code1.id)
        end
      end
    end
  end

  describe '#set_scene_attributes' do
    let(:media)           { FactoryBot.create(:media, title: ['Test Media']) }
    let(:params)          { ActionController::Parameters.new( { "media" =>{} } ) }
    let(:scene)           { Scene.new(media_id: media.id, aleph_scene: old_aleph_scene) }
    let(:old_aleph_scene) { { "scene"=>{"rotation"=>[0, 0, 0] } } }
    let(:aleph_scene)     { { "scene"=>{"rotation"=>[1, 2, 3] } }.to_json}

    before do
      allow(subject).to receive(:params).and_return(params)
      allow(subject).to receive(:curation_concern).and_return(media)
      params["media"]["aleph_scene"] = aleph_scene
    end

    context 'current_user does not exist' do
      before do
        allow(subject).to receive(:current_user).and_return(nil)
        scene.save
      end

      it 'does not change the media scene' do
        expect(media.scene.aleph_scene).to eq(old_aleph_scene)
        subject.send(:set_scene_attributes)
        expect(media.scene.aleph_scene).to eq(old_aleph_scene)
      end
    end

    context 'current_user exists' do
      context 'current_user does not have edit access to the media' do
        before do
          allow(subject).to receive_message_chain(:current_user, :can?).with(:edit, media).and_return(false)
          scene.save
        end

        it 'does not change the media scene' do
          expect(media.scene.aleph_scene).to eq(old_aleph_scene)
          subject.send(:set_scene_attributes)
          expect(media.scene.aleph_scene).to eq(old_aleph_scene)
        end
      end

      context 'current_user has edit access to the media' do
        before do
          allow(subject).to receive_message_chain(:current_user, :can?).with(:edit, media).and_return(true)
        end
        context 'aleph scene parameters are not present' do
          before do
            scene.save
            params["media"].delete("aleph_scene")
          end

          it 'does not change the media scene' do
            expect(media.scene.aleph_scene).to eq(old_aleph_scene)
            subject.send(:set_scene_attributes)
            expect(media.scene.aleph_scene).to eq(old_aleph_scene)
          end
        end

        context 'aleph scene parameters are present' do
          context 'aleph scene is blank' do
            context 'aleph scene is nil or empty string' do
              let(:aleph_scene) { '' }

              context 'a scene is already set' do
                before do
                  scene.save
                end

                it 'destroys the existing scene' do
                  expect(media.scene).to eq(scene)
                  subject.send(:set_scene_attributes)
                  expect(media.scene).to be_nil
                end
              end

              context 'no scene is set' do
                it 'does not set an aleph scene' do
                  expect(media.scene).to be_nil
                  subject.send(:set_scene_attributes)
                  expect(media.scene).to be_nil
                end
              end
            end

            context 'aleph scene is a "null" string' do
              let(:aleph_scene) { "null" }

              context 'a scene is already set' do
                before do
                  scene.save
                end

                it 'destroys the existing scene' do
                  expect(media.scene).to eq(scene)
                  subject.send(:set_scene_attributes)
                  expect(media.scene).to be_nil
                  # No error flash message
                  expect(subject.flash[:error]).to be_nil
                end
              end

              context 'no scene is set' do
                it 'does not set an aleph scene' do
                  expect(media.scene).to be_nil
                  subject.send(:set_scene_attributes)
                  expect(media.scene).to be_nil
                  # No error flash message
                  expect(subject.flash[:error]).to be_nil
                end
              end
            end
          end

          context 'aleph scene is not valid JSON' do
            let(:aleph_scene) { 'not valid JSON' }

            context 'a scene is already set' do
              before do
                scene.save
              end

              it 'does not change the media scene' do
                expect(media.scene.aleph_scene).to eq(old_aleph_scene)
                subject.send(:set_scene_attributes)
                expect(media.scene.aleph_scene).to eq(old_aleph_scene)
                expect(subject.flash[:error]).to eq(I18n.t('morphosource.media.annotations.aleph_scene.invalid_json'))
              end
            end

            context 'no scene is set' do
              it 'does not set an aleph scene' do
                expect(media.scene).to be_nil
                subject.send(:set_scene_attributes)
                expect(media.scene).to be_nil
              end
            end
          end

          context 'scene is not a valid Scene' do
            before do
              scene.save
              allow_any_instance_of(Scene).to receive(:media_id).and_return(nil)
            end

            it 'does not change the media scene' do
              expect(media.scene.aleph_scene).to eq(old_aleph_scene)
              subject.send(:set_scene_attributes)
              expect(media.scene.aleph_scene).to eq(old_aleph_scene)
              expect(subject.flash[:error]).to eq(I18n.t('morphosource.media.annotations.aleph_scene.invalid_scene', errors: "Media can't be blank"))
            end
          end

          context 'aleph scene is the default sketchfab export' do
            let(:aleph_scene) { {  "scene"=> {
                                     "rotation"=>[0, 0, 0],
                                     "environmentMap"=>"warehouse",
                                     "ambientLightIntensity"=>0},
                                     "annotations"=>[]
                                }.to_json
                              }

            it 'sets an aleph scene' do
              expect(media.scene).to be_nil
              subject.send(:set_scene_attributes)
              expect(media.scene.aleph_scene).to eq(JSON.parse(aleph_scene))
              expect(subject.flash[:info]).to eq(I18n.t('morphosource.media.annotations.aleph_scene.save_success'))
            end
          end

          context 'aleph scene is a valid scene' do
            let(:aleph_scene) { {"annotations"=> [
                                  { "label"=>"Travel theodolite, Billwiller Kradolfer",
                                      "position"=> {
                                        "x"=>0.008011947585648348,
                                        "y"=>0.18567544695353352,
                                        "z"=>-0.04208944511806261
                                      },
                                      "cameraPosition"=> {
                                        "x"=>0.011442087529826544,
                                        "y"=>0.17435838282847727,
                                        "z"=>-0.3011810526256875
                                      },
                                      "cameraTarget"=> {
                                        "x"=>0.006860075647615113,
                                        "y"=>0.11044281525164128,
                                        "z"=>-0.005897521905248231
                                      }
                                    },
                                    { "label"=>"Manufacturer",
                                      "position"=> {
                                        "x"=>-0.021920588724995194,
                                        "y"=>0.09161361045876201,
                                        "z"=>-0.0008553354323913129
                                      },
                                      "cameraPosition"=> {
                                        "x"=>-0.06860750404834369,
                                        "y"=>0.17280698445153886,
                                        "z"=>0.03357261536142791
                                      },
                                      "cameraTarget"=> {
                                        "x"=>0.006860075647615112,
                                        "y"=>0.11044281525164128,
                                        "z"=>-0.005897521905248228
                                      }
                                    },
                                  ],
                                  "scene"=> {
                                    "ambientLightIntensity"=>0,
                                    "environmentMap"=>"warehouse",
                                    "rotation"=>[0, 0, 0]
                                  }
                                }.to_json
                              }

            it 'sets an aleph scene' do
              expect(media.scene).to be_nil
              subject.send(:set_scene_attributes)
              expect(media.scene.aleph_scene).to eq(JSON.parse(aleph_scene))
              expect(subject.flash[:info]).to eq(I18n.t('morphosource.media.annotations.aleph_scene.save_success'))
            end
          end
        end
      end
    end
  end

  describe '#characterize' do
    routes { Rails.application.routes }

    let(:admin_user) { FactoryBot.create(:admin) }

    before do
      sign_in admin_user
      # load_and_authorize_resource runs for custom actions; stub authorize! so
      # the double-based media_work passes CanCan without hitting the database.
      allow(controller).to receive(:authorize!).and_return(true)
    end

    context 'with an AF-backed media (file_sets returns a FileSet)' do
      let(:af_file_set) { double('af_file_set', id: 'af-fs-id', original_file: double('orig')) }
      let(:media_work)  { double('media_work', file_sets: [af_file_set], is_remote_backed?: false, valkyrie_member_ids: []) }

      before { allow(Media).to receive(:find).and_return(media_work) }

      it 'enqueues PrepareCharacterizeJob and sets flash notice' do
        expect(PrepareCharacterizeJob).to receive(:perform_later).with('af-fs-id')
        get :characterize, params: { id: 'media-1' }
        expect(flash[:notice]).to eq('Media characterization job has been started')
      end
    end

    context 'with a Valkyrie-backed media (file_sets is empty, valkyrie_member_ids present)' do
      let(:val_file_set) { double('val_file_set', id: Valkyrie::ID.new('val-fs-id')) }
      let(:media_work)   { double('media_work', file_sets: [], is_remote_backed?: false, valkyrie_member_ids: [Valkyrie::ID.new('val-fs-id')]) }

      before do
        allow(val_file_set).to receive(:is_a?).with(Valkyrie::Resource).and_return(true)
        allow(val_file_set).to receive(:present?).and_return(true)
        allow(Media).to receive(:find).and_return(media_work)
        allow(Hyrax.query_service).to receive(:find_by)
          .with(id: Valkyrie::ID.new('val-fs-id'))
          .and_return(val_file_set)
      end

      it 'enqueues PrepareCharacterizeJob via Valkyrie file set and sets flash notice' do
        expect(PrepareCharacterizeJob).to receive(:perform_later).with('val-fs-id')
        get :characterize, params: { id: 'media-1' }
        expect(flash[:notice]).to eq('Media characterization job has been started')
      end
    end

    context 'with a Valkyrie-backed remote media (is_remote_backed? true)' do
      let(:val_file_set) { double('val_file_set', id: Valkyrie::ID.new('val-fs-id')) }
      let(:media_work)   { double('media_work', file_sets: [], is_remote_backed?: true, valkyrie_member_ids: [Valkyrie::ID.new('val-fs-id')]) }

      before do
        allow(val_file_set).to receive(:is_a?).with(Valkyrie::Resource).and_return(true)
        allow(val_file_set).to receive(:present?).and_return(true)
        allow(Media).to receive(:find).and_return(media_work)
        allow(Hyrax.query_service).to receive(:find_by)
          .with(id: Valkyrie::ID.new('val-fs-id'))
          .and_return(val_file_set)
      end

      it 'enqueues PrepareCharacterizeJob directly (skips JobIoWrapper check) and sets flash notice' do
        expect(PrepareCharacterizeJob).to receive(:perform_later).with('val-fs-id')
        get :characterize, params: { id: 'media-1' }
        expect(flash[:notice]).to eq('Media characterization job has been started')
      end
    end

    context 'when no FileSet exists' do
      let(:media_work) { double('media_work', file_sets: [], is_remote_backed?: false, valkyrie_member_ids: []) }

      before { allow(Media).to receive(:find).and_return(media_work) }

      it 'sets a flash error and does not enqueue' do
        expect(PrepareCharacterizeJob).not_to receive(:perform_later)
        get :characterize, params: { id: 'media-1' }
        expect(flash[:error]).to be_present
      end
    end
  end

  describe '#create_derivatives' do
    routes { Rails.application.routes }

    let(:admin_user) { FactoryBot.create(:admin) }

    before do
      sign_in admin_user
      allow(controller).to receive(:authorize!).and_return(true)
    end

    context 'with an AF-backed media (file_sets returns a FileSet)' do
      let(:af_file_set) { double('af_file_set', id: 'af-fs-id', original_file: double('orig')) }
      let(:media_work)  { double('media_work', file_sets: [af_file_set], is_remote_backed?: false, valkyrie_member_ids: []) }

      before { allow(Media).to receive(:find).and_return(media_work) }

      it 'enqueues PrepareCreateDerivativesJob and sets flash notice' do
        expect(PrepareCreateDerivativesJob).to receive(:perform_later).with('af-fs-id')
        get :create_derivatives, params: { id: 'media-1' }
        expect(flash[:notice]).to eq('Media create derivatives job has been started')
      end
    end

    context 'with a Valkyrie-backed media (file_sets is empty, valkyrie_member_ids present)' do
      let(:val_file_set) { double('val_file_set', id: Valkyrie::ID.new('val-fs-id')) }
      let(:media_work)   { double('media_work', file_sets: [], is_remote_backed?: false, valkyrie_member_ids: [Valkyrie::ID.new('val-fs-id')]) }

      before do
        allow(val_file_set).to receive(:is_a?).with(Valkyrie::Resource).and_return(true)
        allow(val_file_set).to receive(:present?).and_return(true)
        allow(Media).to receive(:find).and_return(media_work)
        allow(Hyrax.query_service).to receive(:find_by)
          .with(id: Valkyrie::ID.new('val-fs-id'))
          .and_return(val_file_set)
      end

      it 'enqueues PrepareCreateDerivativesJob via Valkyrie file set and sets flash notice' do
        expect(PrepareCreateDerivativesJob).to receive(:perform_later).with('val-fs-id')
        get :create_derivatives, params: { id: 'media-1' }
        expect(flash[:notice]).to eq('Media create derivatives job has been started')
      end
    end

    context 'with a Valkyrie-backed remote media (is_remote_backed? true)' do
      let(:val_file_set) { double('val_file_set', id: Valkyrie::ID.new('val-fs-id')) }
      let(:media_work)   { double('media_work', file_sets: [], is_remote_backed?: true, valkyrie_member_ids: [Valkyrie::ID.new('val-fs-id')]) }

      before do
        allow(val_file_set).to receive(:is_a?).with(Valkyrie::Resource).and_return(true)
        allow(val_file_set).to receive(:present?).and_return(true)
        allow(Media).to receive(:find).and_return(media_work)
        allow(Hyrax.query_service).to receive(:find_by)
          .with(id: Valkyrie::ID.new('val-fs-id'))
          .and_return(val_file_set)
      end

      it 'enqueues PrepareCreateDerivativesJob directly (skips JobIoWrapper check) and sets flash notice' do
        expect(PrepareCreateDerivativesJob).to receive(:perform_later).with('val-fs-id')
        get :create_derivatives, params: { id: 'media-1' }
        expect(flash[:notice]).to eq('Media create derivatives job has been started')
      end
    end

    context 'when no FileSet exists' do
      let(:media_work) { double('media_work', file_sets: [], is_remote_backed?: false, valkyrie_member_ids: []) }

      before { allow(Media).to receive(:find).and_return(media_work) }

      it 'sets a flash error and does not enqueue' do
        expect(PrepareCreateDerivativesJob).not_to receive(:perform_later)
        get :create_derivatives, params: { id: 'media-1' }
        expect(flash[:error]).to be_present
      end
    end
  end
end
