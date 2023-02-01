# Generated via
#  `rails generate hyrax:work Media`
require 'rails_helper'
include ActionDispatch::TestProcess
include Warden::Test::Helpers

RSpec.describe Hyrax::MediaController, type: :controller do
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
          it 'is unauthorized' do
            get :showcase, params: { id: work.id }
            expect(response.status).to eq(401)
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
        it 'redirects to sign in' do
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

    describe 'interactions with private media and temporary link access cookie' do
      let(:temporary_link) { create(:temporary_media_access_link, user: user, media_id: work.id )} 
      let(:cookie_jar) { ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar }
      let(:main_app) { Rails.application.routes.url_helpers }

      before do
        allow(subject).to receive(:cookies).and_return(cookie_jar)
      end

      context 'user is not logged in but has a temporary access cookie' do
        it 'redirects to media temporary link view URL' do
          cookie_jar.encrypted[temporary_link.media_id] = { 
            value: temporary_link.token, 
            expires: temporary_link.expires_at
          }

          get :showcase, params: { id: work.id }
          expect(response.status).to eq(302)
          expect(response).to redirect_to main_app.media_showcase_temporary_link_path(
            id: work.id, token: temporary_link.token, locale: 'en'
          )
        end
      end

      context 'user is logged in, has temporary access cookie, but already has access to media' do
        before do
          sign_in user
          work.read_users += [user]
          work.save
        end

        it 'does not redirect and successfully returns media via usual route' do
          cookie_jar.encrypted[temporary_link.media_id] = { 
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

        it 'redirects to media temporary link view URL' do
          cookie_jar.encrypted[temporary_link.media_id] = { 
            value: temporary_link.token, 
            expires: temporary_link.expires_at
          }
          get :showcase, params: { id: work.id }
          expect(response.status).to eq(302)
          expect(response).to redirect_to main_app.media_showcase_temporary_link_path(
            id: work.id, token: temporary_link.token, locale: 'en'
          )
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

  describe "#set_fileset_visibility" do
    let(:work)        { Media.new(title: ["Test Media Work"]) }
    let(:file_set_1)  { FileSet.new }

    before do
      allow(subject).to receive(:curation_concern).and_return(work)
      work.ordered_members << file_set_1
    end

    context 'when user selects "open" publication status' do
      before do
        allow(subject).to receive(:params).and_return({"media"=> {"visibility" => public}})
        subject.send(:set_fileset_visibility)
      end

      it 'sets work visibility param to "open"' do
        expect(subject.params["media"]["visibility"]).to eq(public)
      end
      it 'sets work.fileset_visibility to ""' do
        expect(subject.curation_concern.fileset_visibility).to match_array([""])
      end
      it 'sets work.fileset_accessibility and fileSet.accessibility to "open"' do
        expect(subject.curation_concern.fileset_accessibility).to match_array(["open"])
        expect(subject.curation_concern.file_sets.first.accessibility).to match_array(["open"])
      end
    end

    context 'when user selects "restricted_download" publication status' do
      before do
        allow(subject).to receive(:params).and_return({"media"=> {"visibility" => "restricted_download"}})
        subject.send(:set_fileset_visibility)
      end

      it 'sets work visibility param to "open"' do
        expect(subject.params["media"]["visibility"]).to eq(public)
      end
      it 'sets work.fileset_visibility to ""' do
        expect(subject.curation_concern.fileset_visibility).to match_array([""])
      end
      it 'sets work.fileset_accessibility and fileSet.accessibility to "restricted_download"' do
        expect(subject.curation_concern.fileset_accessibility).to match_array(["restricted_download"])
        expect(subject.curation_concern.file_sets.first.accessibility).to match_array(["restricted_download"])
      end
    end

    context 'when user selects "preview" publication status' do
      before do
        allow(subject).to receive(:params).and_return({"media"=> {"visibility" => "preview"}})
        subject.send(:set_fileset_visibility)
      end

      it 'sets work visibility param to "open"' do
        expect(subject.params["media"]["visibility"]).to eq(public)
      end
      it 'sets work.fileset_visibility to ""' do
        expect(subject.curation_concern.fileset_visibility).to match_array([""])
      end
      it 'sets work.fileset_accessibility and fileSet.accessibility to "preview_only"' do
        expect(subject.curation_concern.fileset_accessibility).to match_array(["preview_only"])
        expect(subject.curation_concern.file_sets.first.accessibility).to match_array(["preview_only"])
      end
    end

    context 'when user selects "hidden" publication status' do
      before do
        allow(subject).to receive(:params).and_return({"media"=> {"visibility" => "hidden"}})
        subject.send(:set_fileset_visibility)
      end

      it 'sets work visibility param to "open"' do
        expect(subject.params["media"]["visibility"]).to eq(public)
      end
      it 'sets work.fileset_visibility to "restricted"' do
        expect(subject.curation_concern.fileset_visibility).to match_array(["restricted"])
      end
      it 'sets work.fileset_accessibility and fileSet.accessibility to "hidden"' do
        expect(subject.curation_concern.fileset_accessibility).to match_array(["hidden"])
        expect(subject.curation_concern.file_sets.first.accessibility).to match_array(["hidden"])
      end
    end

    context 'when user selects "private" publication status' do
      before do
        allow(subject).to receive(:params).and_return({"media"=> {"visibility" => private}})
        subject.send(:set_fileset_visibility)
      end

      it 'sets work visibility param to "restricted"' do
        expect(subject.params["media"]["visibility"]).to eq(private)
      end
      it 'sets work.fileset_visibility to ""' do
        expect(subject.curation_concern.fileset_visibility).to match_array([""])
      end
      it 'sets work.fileset_accessibility and fileSet.accessibility to "private"' do
        expect(subject.curation_concern.fileset_accessibility).to match_array(["private"])
        expect(subject.curation_concern.file_sets.first.accessibility).to match_array(["private"])
      end
    end

    context 'when user selects "embargo" publication status' do
      before do
        allow(subject).to receive(:params).and_return({"media"=> {"visibility" => embargo}})
        subject.send(:set_fileset_visibility)
      end

      it 'sets work visibility param to "embargo"' do
        expect(subject.params["media"]["visibility"]).to eq(embargo)
      end
      it 'sets work.fileset_visibility to ""' do
        expect(subject.curation_concern.fileset_visibility).to match_array([""])
      end
      it 'sets work.fileset_accessibility and fileSet.accessibility to ""' do
        expect(subject.curation_concern.fileset_accessibility).to match_array([""])
        expect(subject.curation_concern.file_sets.first.accessibility).to match_array([""])
      end
    end

    context 'when user selects "lease" publication status' do
      before do
        allow(subject).to receive(:params).and_return({"media"=> {"visibility" => lease}})
        subject.send(:set_fileset_visibility)
      end

      it 'sets work visibility param to "lease"' do
        expect(subject.params["media"]["visibility"]).to eq(lease)
      end
      it 'sets work.fileset_visibility to ""' do
        expect(subject.curation_concern.fileset_visibility).to match_array([""])
      end
      it 'sets work.fileset_accessibility and fileSet.accessibility to ""' do
        expect(subject.curation_concern.fileset_accessibility).to match_array([""])
        expect(subject.curation_concern.file_sets.first.accessibility).to match_array([""])
      end
    end
  end

  describe '#after_update_response' do
    let(:curation_concern) { Media.create(title: ["title"]) }
    let(:actor) { double(update: true) }

    routes { Rails.application.routes }
    let(:main_app) { Rails.application.routes.url_helpers }
    let(:hyrax) { Hyrax::Engine.routes.url_helpers }

    let(:file_path1)  { fixture_path + '/images/duke.png' }
    let(:file_path2)  { fixture_path + '/images/ms.jpg' }
    let(:file_path3)  { fixture_path + '/images/ms_2.jpg' }
    let(:local_file1) { File.open(file_path1) }
    let(:local_file2) { File.open(file_path2) }
    let(:local_file3) { File.open(file_path3) }
    let(:file_set_1)   { FileSet.new(visibility: "open") }
    let(:file_set_2)   { FileSet.new(visibility: "open") }
    let(:file_set_3)   { FileSet.new(visibility: "open") }

    let(:fund_code1) { FundCode.new(title: 'Test Fund Code 1', user: depositor)}
    let(:fund_code2) { FundCode.new(title: 'Test Fund Code 2', user: depositor)}

    before do
      sign_in depositor
      allow(Hyrax::CurationConcern).to receive(:actor).and_return(actor)
      allow(Media).to receive(:find).and_return(curation_concern)
      allow(curation_concern).to receive(:visibility_changed?).and_return(false)
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

    # Meets one of the conditions to update file visibility
    context 'saved fileset_visibility is changed' do
      context 'the selected publication status has the same visibility settings for the work and attached files (all except "hidden")' do
        before do
          # results in fileset_visibility_changed? being true
          curation_concern.fileset_visibility = ["restricted"]
        end

        context 'the work permissions are unchanged' do
          before do
            allow(controller).to receive(:permissions_changed?).and_return(false)
            patch :update, params: { id: curation_concern, media: {visibility: "preview"}, action: "update" }
          end

          it 'redirects to permissions/#copy' do
            expect(response).to redirect_to(main_app.copy_hyrax_permission_path(curation_concern, locale: 'en'))
          end
        end

        context 'the work permissions change' do
          before do
            allow(controller).to receive(:permissions_changed?).and_return(true)
            patch :update, params: { id: curation_concern, media: {visibility: "preview"}, action: "update" }
          end

          it 'redirects to permissions/#copy_access' do
            expect(response).to redirect_to(hyrax.copy_access_permission_path(curation_concern, locale: 'en'))
          end
        end
      end

      context 'the user restricts the file visibility by choosing the "hidden" publication status' do
        before do
          # results in fileset_visibility_changed? being true
          curation_concern.fileset_visibility = [""]
        end

        context 'the work permissions change' do
          before do
            allow(controller).to receive(:permissions_changed?).and_return(true)
          end

          it 'calls the InheritPermissionsJob' do
            expect(InheritPermissionsJob).to receive(:perform_later).with(curation_concern)
            patch :update, params: { id: curation_concern, media: {visibility: "hidden"}, action: "update" }
          end
        end

        context 'the work permissions do not change' do
          before do
            allow(controller).to receive(:permissions_changed?).and_return(false)
          end

          it 'does not call the InheritPermissionsJob' do
            expect(InheritPermissionsJob).not_to receive(:perform_later).with(curation_concern)
            patch :update, params: { id: curation_concern, media: {visibility: "hidden"}, action: "update" }
          end
        end

        it "sets the work's filesets' visibilities to 'restricted'" do
          patch :update, params: { id: curation_concern, media: {visibility: "hidden"}, action: "update" }
          expect(file_set_1.visibility).to eq("restricted")
          expect(file_set_2.visibility).to eq("restricted")
          expect(file_set_3.visibility).to eq("restricted")
        end

        it 'redirects to the work show page' do
          patch :update, params: { id: curation_concern, media: {visibility: "hidden"}, action: "update" }
          expect(response).to redirect_to main_app.hyrax_media_path(curation_concern, locale: 'en')
        end

        it 'displays a flash message' do
          patch :update, params: { id: curation_concern, media: {visibility: "hidden"}, action: "update" }
          expect(response.flash[:notice]).to eq('Updating file permissions to restricted. This may take a few minutes. You may want to refresh your browser or return to this record later to see the updated file permissions.')
        end
      end
    end

    context 'fileset_visibility_changed? and curation_concern.visibility_changed? are false' do

      context 'the user selects the same fileset visibility as the work' do
        before do
          # results in fileset_visibility_changed? being false
          curation_concern.fileset_visibility = [""]
          patch :update, params: { id: curation_concern, media: {visibility: "preview"}, action: "update" }
        end

        it 'redirects to the work show page' do
          expect(response).to redirect_to main_app.hyrax_media_path(curation_concern, locale: 'en')
        end

        it 'displays a flash message' do
          expect(response.flash[:notice]).to eq("Work \"#{curation_concern}\" successfully updated.")
        end
      end

      context 'the user restricts the file visibility' do
        before do
          # results in fileset_visibility_changed? being false
          curation_concern.fileset_visibility = ["restricted"]
          patch :update, params: { id: curation_concern, media: {visibility: "hidden"}, action: "update" }
        end

        it 'redirects to the work show page' do
          expect(response).to redirect_to main_app.hyrax_media_path(curation_concern, locale: 'en')
        end

        it 'displays a flash message' do
          expect(response.flash[:notice]).to eq("Work \"#{curation_concern}\" successfully updated.")
        end
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
end
