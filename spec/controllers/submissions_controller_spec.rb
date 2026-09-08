require 'rails_helper'

RSpec.describe SubmissionsController, type: :controller do

  let(:user)          { FactoryBot.build(:confirmed_user) }
  let(:contributors)  { Role.create(name: 'contributor') }
  let(:remote_file_submitters)  { Role.create(name: 'remote_file_submitter') }

  before do
    contributors.users << user
    contributors.save
    sign_in user
  end

  describe '#search_po_ajax' do
    let(:form_params) { { submission: { } } }

    it 'should return js' do
      post :search_po_ajax, params: form_params, xhr: true
      expect(response.content_type).to include('text/javascript')
      expect(response).to have_http_status(:success)
    end
  end

  describe '#validate_remote_file_ajax' do

    context 'with user is not remote_file_submitter' do
      let(:params) { { u: "https://www.morphosource.org/banner_image.png", o: "does_not_matter" } }

      before do
        sign_in user
      end

      it 'returns not allowed error' do
        post :validate_remote_file_ajax, params: params, xhr: true
        expect(JSON.parse(response.body)).to include_json(
          "status"=>"error",
          "http_code"=>"",
          "message"=>"The path is invalid or not allowed.  Please make sure you have the permissions and the domain is allowed.",
          "resp_file_ext"=>""
        )
      end
    end

    context 'check org-linked team remote file permissions' do
      let(:depositor)          { FactoryBot.build(:contributor) }
      let(:team)                    { Collection.create(title: ['Team'],
                                      collection_type_gid: team_collection_type.to_global_id,
                                      depositor: user.ms_id, can_submit_remote_files: "Yes",
                                      allowed_remote_source: "www.morphosource.org") }
      let(:org)                 { Organization.create(title: ['org'], institution_code: ['DEF'], team_id: [team.id]) }

      let(:params1) { { u: "https://www.morphosource.org/banner_image.png", o: org.id } }
      let(:params2) { { u: "https://www.notallowed.org/banner_image.png", o: org.id } }

      before do
        remote_file_submitters.users << depositor
        remote_file_submitters.save

        team.create_collection_groups
        team.depositors << depositor
        team.depositors_group.save

        sign_in depositor
      end

      context 'domain allowed' do
        it 'returns success' do
          post :validate_remote_file_ajax, params: params1, xhr: true
          expect(JSON.parse(response.body)).to include_json(
            "status"=>"success",
            "http_code"=>200,
            "message"=>"",
            "resp_file_ext"=>".png"
          )
        end
      end

      context 'domain not allowed' do
        it 'returns error' do
          post :validate_remote_file_ajax, params: params2, xhr: true
          expect(JSON.parse(response.body)).to include_json(
            "status"=>"error",
            "http_code"=>"",
            "message"=>"The path is invalid or not allowed.  Please make sure you have the permissions and the domain is allowed.",
            "resp_file_ext"=>""
          )
        end
      end

      context 'team cannot submit remote files' do
        before do
          team.can_submit_remote_files = "No"
          team.save
        end
        it 'returns error' do
          post :validate_remote_file_ajax, params: params2, xhr: true
          expect(JSON.parse(response.body)).to include_json(
            "status"=>"error",
            "http_code"=>"",
            "message"=>"The path is invalid or not allowed.  Please make sure you have the permissions and the domain is allowed.",
            "resp_file_ext"=>""
          )
        end
      end

      context 'org has no team' do
        before do
          org.team_id = []
          org.save
        end
        it 'returns error' do
          post :validate_remote_file_ajax, params: params2, xhr: true
          expect(JSON.parse(response.body)).to include_json(
            "status"=>"error",
            "http_code"=>"",
            "message"=>"The path is invalid or not allowed.  Please make sure you have the permissions and the domain is allowed.",
            "resp_file_ext"=>""
          )
        end
      end

    end

    context 'check organization collection remote file permissions' do
      let(:depositor)          { FactoryBot.build(:contributor) }
      let(:org)                 { OrganizationCollection.create(
                                  title: ['org'],
                                  depositor: user.ms_id,
                                  institution_code: ['DEF'],
                                  can_submit_remote_files: "No",
                                  allowed_remote_source: "www.morphosource.org") }

      let(:params1) { { u: "https://www.morphosource.org/banner_image.png", o: org.id } }
      let(:params2) { { u: "https://www.notallowed.org/banner_image.png", o: org.id } }

      before do
        remote_file_submitters.users << depositor
        remote_file_submitters.save
        sign_in depositor
      end

      context 'org cannot submit remote files' do
        it 'returns error' do
          post :validate_remote_file_ajax, params: params2, xhr: true
          expect(JSON.parse(response.body)).to include_json(
            "status"=>"error",
            "http_code"=>"",
            "message"=>"The path is invalid or not allowed.  Please make sure you have the permissions and the domain is allowed.",
            "resp_file_ext"=>""
          )
        end
      end

      context 'domain not allowed, with organization member permissions' do
        before do
          org.can_submit_remote_files = "Yes"
          org.save
          org.create_collection_groups
          org.depositors << depositor
          org.depositors_group.save
        end
        it 'returns error' do
          post :validate_remote_file_ajax, params: params2, xhr: true
          expect(JSON.parse(response.body)).to include_json(
            "status"=>"error",
            "http_code"=>"",
            "message"=>"The path is invalid or not allowed.  Please make sure you have the permissions and the domain is allowed.",
            "resp_file_ext"=>""
          )
        end
      end

      context 'domain allowed, without organization member permissions' do
        before do
          org.can_submit_remote_files = "Yes"
          org.save
        end
        it 'returns success' do
          post :validate_remote_file_ajax, params: params1, xhr: true
          expect(JSON.parse(response.body)).to include_json(
            "status"=>"error",
            "http_code"=>"",
            "message"=>"The path is invalid or not allowed.  Please make sure you have the permissions and the domain is allowed.",
            "resp_file_ext"=>""
          )
        end
      end

      context 'domain allowed, with organization member permissions' do
        before do
          org.can_submit_remote_files = "Yes"
          org.save
          org.create_collection_groups
          org.depositors << depositor
          org.depositors_group.save
        end
        it 'returns success' do
          post :validate_remote_file_ajax, params: params1, xhr: true
          expect(JSON.parse(response.body)).to include_json(
            "status"=>"success",
            "http_code"=>200,
            "message"=>"",
            "resp_file_ext"=>".png"
          )
        end
      end
    end

  end

  describe '#organization_default_media_fields' do
    context 'with no organization information' do
      let(:form_params) { {
        parent_media_list: [],
        organization_id: nil,
        biological_specimen_id: nil,
        cho_id: nil
      } }

      it 'returns JSON error response' do
        post :organization_default_media_fields, params: form_params

        expect(JSON.parse(response.body)).to include_json(
          status: 'FAIL',
          message: 'Organization does not exist',
          default_fields: {},
          organization_alert_message: '',
          organization_title: ''
        )
      end
    end

    context 'with organization information' do
      let(:form_params) { {
        organization_id: '012345678'
      }}

      let(:organization) { Organization.new(
        title: ['Test Title'],
        download_reviewer: ['012345'],
        agreement_uri: ['http://agreement.uri'],
        license: ['CC0'],
        rights_statement: ['In Copyright'],
        permits_commercial_use: ['CommercialUsePermitted'],
        permits_3d_use: ['3DPrintingProhibited'],
        rights_holder: ['Name: Fname, Type: Copyright'],
        download_permission: ['restricted_download'],
        morphosource_use_agreement_type: ['Permissive'],
        required_archival_of_published_derivatives: ['EncouragedButNotRequired'],
        preview_mode: ['Interactive/Embeddable']
      ) }

      before do
        organization.save!
      end

      it 'returns JSON organization response' do
        allow(subject).to receive(:find_ancestor_organization).and_return(organization)

        post :organization_default_media_fields, params: form_params

        expect(JSON.parse(response.body)).to include_json(
          status: 'OK',
          message: 'Organization default permission settings retrieved',
          default_fields: {
          'agreement_uri': ['http://agreement.uri'],
          'license': ['CC0'],
          'rights_statement': ['In Copyright'],
          'permits_commercial_use': ['CommercialUsePermitted'],
          'permits_3d_use': ['3DPrintingProhibited'],
          'rights_holder': ['Name: Fname, Type: Copyright'],
          'morphosource_use_agreement_type': ['Permissive'],
          'required_archival_of_published_derivatives': ['EncouragedButNotRequired'],
          'preview_mode': ['Interactive/Embeddable']
          },
          organization_alert_message: 'This value has been suggested by Test Title',
          organization_title: ['Test Title']
        )
      end
    end

    # The create-time Reviewer Eligibility gate. It runs here rather than on the Media
    # validation because that validation walks the new media's ancestors, which the actor
    # stack may not have linked yet, so an empty set would pass vacuously.
    context 'with an organization collection that reviews its objects\' media downloads' do
      let(:user)        { FactoryBot.create(:contributor) }
      let(:form_params) { { organization_id: organization.id } }
      let(:organization) do
        FactoryBot.create(:organization_collection,
                          title: ['Reviewing Org'],
                          depositor: user.ms_id,
                          reviews_object_media_downloads: eligible)
      end

      before { allow(subject).to receive(:find_ancestor_organization).and_return(organization) }

      context 'when the organization is eligible' do
        let(:eligible) { true }

        it 'defaults the new media to object_organization mode' do
          post :organization_default_media_fields, params: form_params

          default_fields = JSON.parse(response.body)['default_fields']
          expect(default_fields['download_reviewer_mode']).to eq('object_organization')
          expect(default_fields).not_to have_key('reviews_object_media_downloads')
        end
      end

      context 'when the organization is not eligible' do
        let(:eligible) { false }

        it 'sets no mode, and does not raise on the scalar flag' do
          post :organization_default_media_fields, params: form_params

          default_fields = JSON.parse(response.body)['default_fields']
          expect(default_fields).not_to have_key('download_reviewer_mode')
          expect(default_fields).not_to have_key('reviews_object_media_downloads')
        end
      end

      context 'when the flag has never been written' do
        let(:eligible) { nil }

        it 'sets no mode' do
          post :organization_default_media_fields, params: form_params

          expect(JSON.parse(response.body)['default_fields']).not_to have_key('download_reviewer_mode')
        end
      end
    end
  end

  # download_reviewer_mode is a permitted form term, so a mode can arrive from the client
  # rather than from an organization's defaults. Media's own validation cannot gate it at
  # create time: it walks ancestors the actor stack may not have linked yet, so an empty set
  # passes vacuously, and nothing re-checks afterwards.
  describe '#reject_ineligible_reviewer_mode' do
    let(:posted)  { ActionController::Parameters.new('download_reviewer_mode' => 'object_organization') }
    let(:eligible) { nil }
    let(:organization) do
      FactoryBot.create(:organization_collection,
                        title: ['Posting Org'],
                        depositor: user.ms_id,
                        reviews_object_media_downloads: eligible)
    end

    before { allow(subject).to receive(:find_ancestor_organization).and_return(organization) }

    context 'when the organization is eligible' do
      let(:eligible) { true }

      it 'keeps the posted mode' do
        result = subject.send(:reject_ineligible_reviewer_mode, posted)

        expect(result['download_reviewer_mode']).to eq('object_organization')
      end
    end

    context 'when organization review is required' do
      let(:eligible) { true }

      it 'uses object_organization even if the client posts record_users' do
        organization.update!(permissions_enforcement_mode: ['Require'])
        params = ActionController::Parameters.new('download_reviewer_mode' => 'record_users')
        expect(subject.send(:reject_ineligible_reviewer_mode, params)['download_reviewer_mode'])
          .to eq('object_organization')
      end
    end

    it 'persists multiple reviewers through the submission form param path' do
      reviewer = FactoryBot.create(:contributor)
      posted = ActionController::Parameters.new(
        download_reviewer_mode: 'record_users',
        record_download_reviewer_users: ["#{user.ms_id},#{reviewer.ms_id}"],
        download_reviewer: ['legacy-value'])
      fields = Hyrax::MediaForm.model_attributes(subject.send(:reject_ineligible_reviewer_mode, posted))
      media = FactoryBot.create(:media, fields)

      expect(media.reload.record_download_reviewer_users).to match_array([user.ms_id, reviewer.ms_id])
      expect(media.download_reviewer).to be_empty
    end

    context 'when the organization is not eligible' do
      let(:eligible) { false }

      it 'drops the posted mode' do
        result = subject.send(:reject_ineligible_reviewer_mode, posted)

        expect(result).not_to have_key('download_reviewer_mode')
      end
    end

    it 'drops the posted mode when no organization resolves' do
      allow(subject).to receive(:find_ancestor_organization).and_return(nil)

      expect(subject.send(:reject_ineligible_reviewer_mode, posted)).not_to have_key('download_reviewer_mode')
    end

    it 'allows record_users when organization review is not required' do
      params = ActionController::Parameters.new('download_reviewer_mode' => 'record_users')

      expect(subject.send(:reject_ineligible_reviewer_mode, params)['download_reviewer_mode']).to eq('record_users')
    end
  end

  # The create-time eligibility gate calls this, so the value @submission carries has to be a
  # single id: parent_media_list is comma-joined when several parents are selected, and
  # Media.find raises on the whole list.
  describe '#find_ancestor_organization' do
    let(:organization) { FactoryBot.create(:organization_collection, title: ['Parent Org']) }
    let(:parent)       { instance_double(Media, organizations: [organization]) }

    it 'resolves the first parent when the submission names several' do
      subject.instance_variable_set(:@submission, Submission.new(parent_media_list: 'aaa,bbb'))
      expect(Media).to receive(:find).with('aaa').and_return(parent)

      expect(subject.send(:find_ancestor_organization)).to eq(organization)
    end

    it 'resolves a single parent unchanged' do
      subject.instance_variable_set(:@submission, Submission.new(parent_media_list: 'aaa'))
      expect(Media).to receive(:find).with('aaa').and_return(parent)

      expect(subject.send(:find_ancestor_organization)).to eq(organization)
    end
  end

  describe '#save_data' do
    let(:form_params) { { submission: { 'raw_or_derived_media' => 'raw' } } }

    it 'should save params to session variable' do
      session[:submission] = {}
      post :save_data, params: form_params, xhr: true

      expect(response).to have_http_status(:success)
      expect(session[:submission]).to eq( { 'raw_or_derived_media' => 'raw' } )
    end
  end

  describe '#create' do
    describe 'when provided with correct params' do
      form_params = [
        { work: 'taxonomy_resource', params:
          { taxonomy_resource: { title: ['Test Title'] } }
        },
        { work: 'biological_specimen', params:
          { biological_specimen: { title: ['Test Title'] } }
        },
        { work: 'cultural_heritage_object', params:
          { cultural_heritage_object: { title: ['Test Title'] } }
        },
        { work: 'imaging_event', params:
          { imaging_event: { title: ['Test Title'] },
            submission: {
              biological_specimen_or_cultural_heritage_object: 'bso',
              biological_specimen_id: '012345678',
              device_id: '012345678'
            }
          }
        },
        { work: 'processing_event', params:
          { processing_event: { title: ['Test Title'] },
            submission: {
              parent_media_not_in_ms: true,
              imaging_event_id: '012345678'
            }
          }
        },
        { work: 'media', params:
          { media: { title: ['Test Title'] },
            submission: {
              raw_or_derived_media: 'raw',
              imaging_event_id: '012345678'
            }
          }
        }
      ]

      form_params.each do |fp|
        it "tries to create #{fp[:work]} work" do
          session[:submission] = {}
          allow(subject).to receive(:assign_model_params_parents).and_return({ 'title' => ['Test Title'], 'visibility' =>
          'restricted_download' })
          expect(subject).to receive(:create_work)
          post :create, params: fp[:params]
        end
      end
    end

    describe 'when not provided with correct params' do
      let(:form_params) { { } }

      it 'does not try to create work' do
        expect(subject).not_to receive(:create_work)
        post :create, params: form_params
      end
    end

    it 'calls reindex_catalog_works' do
      expect(subject).to receive(:reindex_catalog_works)
      post :create, params: {}
    end
  end

  describe '#reindex_catalog_works' do
    let(:submission)    { double('Submission', media_id: media.id) }

    let(:media)         { Media.create(title: ['New Media']) }
    let(:old_m_solr)    { SolrDocument.find(media.id) }
    let(:new_m_solr)    { SolrDocument.find(media.id) }

    let(:organization)  { Organization.create(title: ['Organization'] ) }

    let(:specimen)      { BiologicalSpecimen.create(title: ['Specimen'], vouchered: ['Yes'], organization_id: [organization.id]) }
    let(:old_s_solr)    { SolrDocument.find(specimen.id) }
    let(:new_s_solr)    { SolrDocument.find(specimen.id) }

    let(:device)        { FactoryBot.valkyrie_create(:device_resource, title: ['test device'], modality: ['Photogrammetry']) }

    let(:imaging_event) { ImagingEvent.create(title: ['Imaging Event'], device_id: [device.id.to_s], physical_object_id: [specimen.id], ie_modality: device.modality) }

    let(:old_solr_docs) { [old_m_solr, old_s_solr] }

    before do
      imaging_event.members << media
      [specimen, imaging_event].each(&:save)
      subject.instance_variable_set(:@submission, submission)
    end

    it 'reindexes each catalog work' do
      old_solr_docs
      subject.send(:reindex_catalog_works)
      expect(old_m_solr['_version_']).not_to eq(new_m_solr['_version'])
      expect(old_s_solr['_version_']).not_to eq(new_s_solr['_version'])
    end
  end
end
