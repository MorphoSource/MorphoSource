require 'rails_helper'

RSpec.describe SubmissionsController, type: :controller do

  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
  end

  describe '#search_po_ajax' do
    let(:form_params) { { submission: { } } }

    it 'should return js' do
      post :search_po_ajax, params: form_params, xhr: true
      expect(response.content_type).to eq('text/javascript')
      expect(response).to have_http_status(:success)
    end
  end

  describe '#set_up_media_permissions' do
    let(:download_reviewer)       { ['abc123'] }
    let(:agreement_uri)           { ["www.agreement.uri"] }
    let(:rights_statement)        { ["http://rightsstatements.org/vocab/InC-EDU/1.0/"] }
    let(:terms_of_use)            { ["organization a terms of use"] }
    let(:permits_commercial_use)  { ["true"] }
    let(:permits_3d_use)          { ['false'] }
    let(:rights_holder)           { ["Name: Name 1, Type: Copyright"] }
    let(:funding)                 { ["funding"] }
    let(:license)                 { ["http://creativecommons.org/publicdomain/zero/1.0/"] }
    let(:publisher)               { ["publisher 1"] }
    let(:cite_as)                 { ["cite as cite as cite as"] }
    let(:download_permission)     { [Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC] }
    let(:specimen)                { BiologicalSpecimen.new(id: 'spec_id') }
    # specimen 2 does not belong to an organization
    let(:specimen2)               { BiologicalSpecimen.new(id: 'spec2_id') }
    # specimen 3's organization does not have defualt permissions
    let(:specimen3)               { BiologicalSpecimen.new(id: 'spec3_id') }
    let(:cho)                     { CulturalHeritageObject.new(id: 'cho_id') }
    # cho2 does not belong to an organization
    let(:cho2)                    { CulturalHeritageObject.new(id: 'cho2_id') }
    let(:parent)                  { Media.new(id: 'parent') }
    # parent2 does not belong to an organization
    let(:parent2)                 { Media.new(id: 'parent2') }
    # parent3's organization does not have default permissions
    let(:parent3)                 { Media.new(id: 'parent3') }
    let(:organization)            { Organization.new(
                                      id: 'org_id',
                                      download_reviewer: download_reviewer,
                                      agreement_uri: agreement_uri,
                                      rights_statement: rights_statement,
                                      permits_commercial_use: permits_commercial_use,
                                      permits_3d_use: permits_3d_use,
                                      rights_holder: rights_holder,
                                      funding: funding,
                                      license: license,
                                      publisher: publisher,
                                      cite_as: cite_as,
                                      download_permission: download_permission) }
    let(:organization2)           { Organization.new(id: 'org2') }
    let(:default_permissions)     { { download_reviewer: download_reviewer,
                                      agreement_uri: agreement_uri,
                                      rights_statement: rights_statement,
                                      permits_commercial_use: permits_commercial_use,
                                      permits_3d_use: permits_3d_use,
                                      rights_holder: rights_holder,
                                      funding: funding,
                                      license: license,
                                      publisher: publisher,
                                      cite_as: cite_as,
                                      download_permission: download_permission.first } }
    let(:empty_permissions)       { { download_reviewer: [],
                                      agreement_uri: [],
                                      rights_statement: [],
                                      permits_commercial_use: [],
                                      permits_3d_use: [],
                                      rights_holder: [],
                                      funding: [],
                                      license: [],
                                      publisher: [],
                                      cite_as: [] } }
    let(:form_params)             { { submission:
                                      { biospec_id: biospec_id,
                                        parent_media_list: parent_media_list,
                                        cho_id: cho_id,
                                        organization_id: organization_id },
                                      processing_event:
                                      { processing_activity_step: ["1"] }, biospec_select: 'foo' } }
    let(:media)                    { subject.instance_variable_get(:@media_form).model }

    before do
      @request.session['submission'] = {}
      allow(Organization).to receive(:find).with(organization.id).and_return(organization)
      allow(Organization).to receive(:find).with(organization2.id).and_return(organization2)
    end

    it 'renders the media view' do
      expect(subject).to receive(:render_and_save).with('media')
      subject.send(:set_up_media_permissions)
    end

    context 'the media does not have a parent in morphosource' do
      let(:parent_media_list)       { nil }

      context 'the media represents a biological specimen' do
        let(:cho_id)          { nil }

        before do
          allow(BiologicalSpecimen).to receive(:find).with(specimen.id).and_return(specimen)
          allow(BiologicalSpecimen).to receive(:find).with(specimen2.id).and_return(specimen2)
          allow(BiologicalSpecimen).to receive(:find).with(specimen3.id).and_return(specimen3)
          allow(specimen2).to receive(:organizations).and_return([])
          allow(specimen).to receive(:organizations).and_return([organization])
          allow(specimen3).to receive(:organizations).and_return([organization2])
          post :stage_processing_event, params: form_params
        end

        context 'the user adds a new specimen' do
          let(:biospec_id)      { 'new' }
          context 'the new specimen is linked to a new organization' do
            let(:organization_id) { 'new' }

            it 'does not assign default permissions' do
              expect(media).to have_attributes(empty_permissions)
            end
          end
          context 'the new specimen is linked to an old organization' do
            context 'the old organization has default permissions set' do
              let(:organization_id) { organization.id }

              it 'assigns default permissions' do
                expect(media).to have_attributes(default_permissions)
              end
            end
            context 'the old organization does not have default permissions set' do
              let(:organization_id) { organization2.id }

              it 'does not assign default permissions' do
                expect(media).to have_attributes(empty_permissions)
              end
            end
          end
        end

        context 'the user links to an existing specimen' do
          context 'the specimen belongs to an organization' do
            context 'the organization has default permissions set' do
              let(:biospec_id)      { specimen.id }
              let(:organization_id) { nil }

              it 'assigns default permissions' do
                expect(media).to have_attributes(default_permissions)
              end
            end
            context 'the organization does not have default permissions set' do
              let(:biospec_id)      { specimen3.id }
              let(:organization_id) { nil }

              it 'assigns default permissions' do
                expect(media).to have_attributes(empty_permissions)
              end
            end
          end
          context 'the specimen does not have an organization' do
            let(:biospec_id)      { specimen2.id }
            let(:organization_id) { nil }

            it 'does not assign permissions' do
              expect(media).to have_attributes(empty_permissions)
            end
          end
        end
      end
      context 'the media represents a cultural heritage object' do
        let(:biospec_id)     { nil }

        before do
          allow(CulturalHeritageObject).to receive(:find).with(cho.id).and_return(cho)
          allow(CulturalHeritageObject).to receive(:find).with(cho2.id).and_return(cho2)
          allow(cho2).to receive(:organizations).and_return([])
          allow(cho).to receive(:organizations).and_return([organization])
          post :stage_processing_event, params: form_params
        end

        context 'the user adds a new cho' do
          let(:cho_id)       { 'new' }
          context 'the new cho has a new organization' do
            let(:organization_id) { 'new' }

            it 'does not assign default permissions' do
              expect(media).to have_attributes(empty_permissions)
            end
          end
          context 'the new cho is linked to an existing organization' do
            let(:organization_id) { organization.id }

            it 'assigns default permissions' do
              expect(media).to have_attributes(default_permissions)
            end
          end
        end
        context 'the user links to an existing cho' do
          context 'the cho belongs to an organization' do
            let(:cho_id)          { cho.id }
            let(:organization_id) { nil }

            it 'assigns default permissions' do
              expect(media).to have_attributes(default_permissions)
            end
          end
          context 'the cho does not belong to an organization' do
            let(:cho_id)          { cho2.id }
            let(:organization_id) { nil }

            it 'does not assign default permissions' do
              expect(media).to have_attributes(empty_permissions)
            end
          end
        end
      end
    end
    context 'the media has a parent in morphosource' do
      let(:biospec_id)      { nil }
      let(:organization_id) { nil }
      let(:cho_id)          { nil }

      before do
        allow(Media).to receive(:find).with(parent.id).and_return(parent)
        allow(Media).to receive(:find).with(parent2.id).and_return(parent2)
        allow(Media).to receive(:find).with(parent3.id).and_return(parent3)
        allow(parent).to receive(:organizations).and_return([organization])
        allow(parent2).to receive(:organizations).and_return([])
        post :stage_processing_event, params: form_params
        allow(parent3).to receive(:organizations).and_return([organization2])
      end

      context 'the parent media belongs to an organization' do
        context 'the organization has permission defaults set' do
          let(:parent_media_list) { parent.id }

          it 'assigns default permissions' do
            expect(media).to have_attributes(default_permissions)
          end
        end
        context 'the organization does not have permission defaults set' do
          let(:parent_media_list) { parent3.id }

          it 'does not assign default permissions' do
            expect(media).to have_attributes(empty_permissions)
          end
        end
      end
      context 'the parent media does not belong to an organization' do
        let(:parent_media_list) { parent2.id }

        it 'does not assign default permissions' do
          expect(media).to have_attributes(empty_permissions)
        end
      end
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
        { work: 'organization', params: 
          { organization: { title: ['Test Title'] } }  
        },
        { work: 'device_organization', params: 
          { device_organization: { title: ['Test Title'] } }
        },
        { work: 'taxonomy', params: 
          { taxonomy: { title: ['Test Title'] } }
        },
        { work: 'biological_specimen', params: 
          { biological_specimen: { title: ['Test Title'] } } 
        },
        { work: 'cultural_heritage_object', params: 
          { cultural_heritage_object: { title: ['Test Title'] } }
        },
        { work: 'device', params: 
          { device: { title: ['Test Title'] } }
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
  end
end
