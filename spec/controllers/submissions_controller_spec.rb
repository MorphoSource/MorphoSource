require 'rails_helper'

RSpec.describe SubmissionsController, type: :controller do

  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
  end

  describe '#create' do
    describe 'biospec_search' do
      let(:form_params) { { submission: {}, biospec_search: 'foo' } }
      it 'runs a biospec search' do
        expect(subject).to receive(:search_biospec)
        post :create, params: form_params
      end
      it 'renders the biospec view' do
        post :create, params: form_params
        expect(response).to render_template(:biospec)
      end
    end

    describe 'biospec_select' do
      let(:biospec_id) { 'abc123' }
      let(:form_params) { { submission: { biospec_id: biospec_id }, biospec_select: 'foo' } }
      before do
        @request.session['submission'] = {}
      end
      it 'sets the biospec id in the session' do
        post :create, params: form_params
        expect(@request.session[:submission]).to include({ biospec_id: biospec_id })
      end
      it 'renders the device view' do
        post :create, params: form_params
        expect(response).to render_template(:device)
      end
    end

    describe 'organization_select when creating new BSO' do
      let(:saved_step) {'biospec_will_create'}
      let(:organization_id) { 'abc123' }
      let(:form_params) { { submission: { organization_id: organization_id }, organization_select: 'foo' } }
      before do
        @request.session['submission'] = {saved_step: saved_step}
      end
      it 'sets the organization id in the session' do
        post :create, params: form_params
        expect(@request.session[:submission]).to include({ organization_id: organization_id })
      end
      it 'renders the biospec create view' do
        post :create, params: form_params
        expect(response).to render_template(:taxonomy)
      end
    end

    describe 'device_organization_select when creating new device' do
      let(:saved_step) {'device_will_create'}
      let(:organization_id) { 'abc123' }
      let(:form_params) { { submission: { device_organization_id: organization_id }, organization_select: 'foo' } }
      before do
        @request.session['submission'] = {saved_step: saved_step}
      end
      it 'sets the device organization id in the session' do
        post :create, params: form_params
        expect(@request.session[:submission]).to include({ device_organization_id: organization_id })
      end
      it 'renders the device create view' do
        post :create, params: form_params
        expect(response).to render_template(:device_create)
      end
    end

    describe 'organization_select when creating new CHO' do
      let(:saved_step) {'cho_will_create'}
      let(:organization_id) { 'abc123' }
      let(:form_params) { { submission: { organization_id: organization_id }, organization_select: 'foo' } }
      before do
        @request.session['submission'] = {saved_step: saved_step}
      end
      it 'sets the organization id in the session' do
        post :create, params: form_params
        expect(@request.session[:submission]).to include({ organization_id: organization_id })
      end
      it 'renders the CHO create view' do
        post :create, params: form_params
        expect(response).to render_template(:cho_create)
      end
    end

    describe 'device_select' do
      before do
        Device.create({
            id: 'abc123',
            title: ['XTekCT 100'],
            creator: ['Nikon'],
            modality: ['MedicalXRayComputedTomography'],
            description: ['A sample description']
        })
        @request.session['submission'] = {}
      end
      let(:device_id) { 'abc123' }
      let(:form_params) { { submission: { device_id: device_id }, device_select: 'XTekCT 100' } }

      it 'sets the device id in the session' do
        post :create, params: form_params
        expect(@request.session[:submission]).to include({ device_id: device_id })
      end

      it 'sets modality_to_set in cookie' do
        post :create, params: form_params
        expect(response.cookies["modality_to_set"]).to eq('MedicalXRayComputedTomography')
      end

      it 'renders the device view' do
        post :create, params: form_params
        expect(response).to render_template(:image_capture)
      end
    end

    describe 'parent_media_select' do
      before do
        ie = ImagingEvent.create(title: ["Test ImagingEvent"], id: "parentIE", ie_modality: ['MedicalXRayComputedTomography'])
        media = Media.create({
            id: 'abc123',
            title: ['media 1']
        })
        ie.ordered_members << media
        ie.save!
        media.save!
        @request.session['submission'] = {}
      end
      let(:media_id) { 'abc123' }
      let(:form_params) { { submission: { parent_media_list: 'abc123' }, parent_media_select: 'media 1' } }

      it 'sets modality_to_set in cookie' do
        post :create, params: form_params
        expect(response.cookies["modality_to_set"]).to eq('MedicalXRayComputedTomography')
      end

      it 'renders the processing event' do
        post :create, params: form_params
        expect(response).to render_template(:processing_event)
      end
    end


    describe 'default' do
      let(:form_params) { { submission: {} } }
      it 'finishes the submission' do
        expect(subject).to receive(:finish_submission)
        post :create, params: form_params
      end
    end
  end

  describe '#stage_biological_specimen' do
    let(:form_attributes) do
      { 'vouchered' => 'Yes', 'catalog_number' => '123', 'collection_code' => 'abc', 'creator' => [ 'Smith, Sam' ] }
    end
    let(:form_params) { { biological_specimen: form_attributes } }
    let(:model_attributes) { form_attributes.transform_values { |value| Array(value) } }
    it 'stores the model attributes in the session' do
      post :stage_biological_specimen, params: form_params
      expect(@request.session[:submission_biospec_create_params]).to include(model_attributes)
    end
    it 'renders the organization view' do
      post :stage_biological_specimen, params: form_params
      expect(response).to render_template(:device)
    end
  end

  describe '#stage_device' do
    let(:form_attributes) do
      { 'title' => 'Device', 'creator' => [ 'Panasonic' ], 'modality' => [ 'Photography' ] }
    end
    let(:form_params) { { device: form_attributes } }
    let(:model_attributes) { form_attributes.transform_values { |value| Array(value) } }
    it 'stores the model attributes in the session' do
      post :stage_device, params: form_params
      expect(@request.session[:submission_device_create_params]).to include(model_attributes)
    end
    it 'sets modality_to_set in cookie' do
      post :stage_device, params: form_params
      expect(response.cookies["modality_to_set"]).to eq('Photography')
    end
    it 'renders the image_capture view' do
      post :stage_device, params: form_params
      expect(response).to render_template(:image_capture)
    end
  end

  describe '#stage_imaging_event' do
    let(:form_attributes) do
      { 'ie_modality' => 'NeutrinoImaging' }
    end
    let(:form_params) { { imaging_event: form_attributes } }
    let(:model_attributes) { form_attributes.transform_values { |value| Array(value) } }
    it 'stores the model attributes in the session' do
      post :stage_imaging_event, params: form_params
      expect(@request.session[:submission_imaging_event_create_params]).to include(model_attributes)
    end
    it 'calls #set_up_media_permissions' do
      expect(subject).to receive(:set_up_media_permissions)
      post :stage_imaging_event, params: form_params
    end
    it 'renders the media view' do
      post :stage_imaging_event, params: form_params
      expect(response).to render_template(:media)
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

  describe '#stage_organization when creating new biospec' do
    let(:saved_step) {'biospec_will_create'}
    before do
      @request.session['submission'] = {saved_step: saved_step}
    end
    let(:form_attributes) do
      { 'title' => 'Organization', 'institution_code' => 'inst' }
    end
    let(:form_params) { { organization: form_attributes } }
    let(:model_attributes) { form_attributes.transform_values { |value| Array(value) } }
    it 'stores the model attributes in the session' do
      post :stage_organization, params: form_params
      expect(@request.session[:submission_organization_create_params]).to include(model_attributes)
    end
    it 'renders the taxonomy page' do
      post :stage_organization, params: form_params
      expect(response).to render_template(:taxonomy)
    end
  end

  describe '#stage_device_organization when creating new device' do
    let(:saved_step) {'device_will_create'}
    before do
      @request.session['submission'] = {saved_step: saved_step}
    end
    let(:form_attributes) do
      { 'title' => 'Organization', 'institution_code' => 'inst' }
    end
    let(:form_params) { { organization: form_attributes } }
    let(:model_attributes) { form_attributes.transform_values { |value| Array(value) } }
    it 'stores the model attributes in the session' do
      post :stage_device_organization, params: form_params
      expect(@request.session[:submission_device_organization_create_params]).to include(model_attributes)
    end
    it 'renders the device create view' do
      post :stage_device_organization, params: form_params
      expect(response).to render_template(:device_create)
    end
  end

  describe '#stage_organization when creating new cho' do
    let(:saved_step) {'cho_will_create'}
    before do
      @request.session['submission'] = {saved_step: saved_step}
    end
    let(:form_attributes) do
      { 'title' => 'Organization', 'institution_code' => 'inst' }
    end
    let(:form_params) { { organization: form_attributes } }
    let(:model_attributes) { form_attributes.transform_values { |value| Array(value) } }
    it 'stores the model attributes in the session' do
      post :stage_organization, params: form_params
      expect(@request.session[:submission_organization_create_params]).to include(model_attributes)
    end
    it 'renders the cho create view' do
      post :stage_organization, params: form_params
      expect(response).to render_template(:cho_create)
    end
  end

  describe '#stage_media' do
    let(:metadata_attributes) do
      { 'media_type' => 'Mesh' }
    end
    let(:uploaded_files) { [ '12', '13' ] }
    let(:visibility) { 'authenticated' }
    let(:visibility_attribute) { { 'visibility' => visibility } }
    let(:form_params) { { media: metadata_attributes.merge(visibility_attribute), uploaded_files: uploaded_files } }
    let(:model_attributes) do
      metadata_attributes.transform_values { |value| Array(value) }.merge(visibility_attribute)
    end
    describe 'session storage' do
      before { allow(subject).to receive(:finish_submission) { nil } }
      it 'stores the model attributes in the session' do
        post :stage_media, params: form_params
        expect(@request.session[:submission_media_create_params]).to include(model_attributes)
      end
      it 'stores the uploaded files in the session' do
        post :stage_media, params: form_params
        expect(@request.session[:submission_media_uploaded_files]).to include(*uploaded_files)
      end
    end
    describe 'next step' do
      it 'finishes the submission' do
        expect(subject).to receive(:finish_submission)
        post :stage_media, params: form_params
      end
    end
  end

  describe '#stage_taxonomy' do
    let(:saved_step) {'biospec_organization_select'}
    before do
      @request.session['submission'] = {saved_step: saved_step}
    end
    let(:form_attributes) do
      { "taxonomy_domain"=> "domain", "taxonomy_kingdom"=> "kingdom", "taxonomy_phylum"=> "phylum", "taxonomy_superclass"=> "superclass", "taxonomy_class"=> "class", "taxonomy_subclass"=> "subclass", "taxonomy_superorder"=> "superorder", "taxonomy_order"=> "order", "taxonomy_suborder"=> "suborder", "taxonomy_superfamily"=> "superfamily", "taxonomy_family"=> "family", "taxonomy_subfamily"=> "subfamily", "taxonomy_tribe"=> "tribe", "taxonomy_genus"=> "genus", "taxonomy_subgenus"=> "subgenus", "taxonomy_species"=> "species", "taxonomy_subspecies"=> "subspecies"}
    end
    let(:form_params) { { taxonomy: form_attributes } }
    let(:model_attributes) { form_attributes.transform_values { |value| Array(value) } }
    it 'stores the model attributes in the session' do
      post :stage_taxonomy, params: form_params
      expect(@request.session[:submission_taxonomy_create_params]).to include(model_attributes)
    end
    it 'renders the biospec create view' do
      post :stage_taxonomy, params: form_params
      expect(response).to render_template(:biospec_create)
    end
  end

  describe '#stage_processing_event' do
    let(:form_params) { { "processing_event" => { "processing_activity_step" => ["1"] } } }
    it 'calls #set_up_media_permissions' do
      expect(subject).to receive(:set_up_media_permissions)
      post :stage_processing_event, params: form_params
    end
  end

  describe '#new_organization_submit' do
    describe 'successfully created a new organization' do
      let(:form_attributes) do
        { 'id' => 'abc',
          'title' => 'Organization',
          'institution_code' => 'inst',
          'description' => 'test',
          'address' => 'test',
          'city' => 'test',
          'state_province' => 'test',
          'country' => 'test'
        }
      end
      let(:form_params) { { organization: form_attributes } }
      it 'return organization data in json response' do
        post :new_organization_submit, params: form_params

        expect(JSON.parse(response.body)).to include_json(
          status: 'OK',
          message: 'New organization created',
          work: {
            title: 'Organization',
            institution_code: 'inst',
            description: 'test',
            address: 'test',
            city: 'test',
            state_province: 'test',
            country: 'test'
          }
        )
      end
    end

    describe 'failed to create a new organization' do
      let(:form_params) { { organization: {} } } # no form attribute will throw an exception
      it 'return failure status in json response' do
        post :new_organization_submit, params: form_params

        expect(JSON.parse(response.body)).to include_json(
          status: 'FAIL',
          message: 'There is a problem creating the organization.',
          work: {}
        )
      end
    end
  end

  describe '#new_taxonomy_submit' do
    describe 'successfully created a new taxonomy' do
      let(:form_attributes) do
        { 'taxonomy_domain' => '1', 'taxonomy_kingdom' => '1', 'taxonomy_phylum' => '1', 'taxonomy_superclass' => '1', 'taxonomy_class' => '1', 'taxonomy_subclass' => '1', 'taxonomy_superorder' => '1', 'taxonomy_order' => '1', 'taxonomy_suborder' => '1', 'taxonomy_superfamily' => '1', 'taxonomy_family' => '1', 'taxonomy_subfamily' => '1', 'taxonomy_tribe' => '1', 'taxonomy_genus' => '1', 'taxonomy_subgenus' => '1', 'taxonomy_species' => '1', 'taxonomy_subspecies' => '1'
        }
      end
      let(:form_params) { { taxonomy: form_attributes } }
      it 'return taxonomy data in json response' do
        post :new_taxonomy_submit, params: form_params

        expect(JSON.parse(response.body)).to include_json(
          status: 'OK',
          message: 'New Taxonomy created',
          work: {
            title: "1 > 1 > 1 > 1 > 1 > 1 > 1 > 1 > 1 > 1 > 1 > 1 > 1 > 1 > 1 > 1 > 1",
            taxonomy_domain:  '1', taxonomy_kingdom:  '1', taxonomy_phylum:  '1', taxonomy_superclass:  '1', taxonomy_class:  '1', taxonomy_subclass:  '1', taxonomy_superorder:  '1', taxonomy_order:  '1', taxonomy_suborder:  '1', taxonomy_superfamily:  '1', taxonomy_family:  '1', taxonomy_subfamily:  '1', taxonomy_tribe:  '1', taxonomy_genus:  '1', taxonomy_subgenus:  '1', taxonomy_species:  '1', taxonomy_subspecies:  '1'
          }
        )
      end
    end

    describe 'failed to create a new taxonomy' do
      let(:form_params) { { taxonomy: {} } } # no form attribute will throw an exception
      it 'return failure status in json response' do
        post :new_taxonomy_submit, params: form_params

        expect(JSON.parse(response.body)).to include_json(
          status: 'FAIL',
          message: 'There is a problem creating the taxonomy.',
          work: {}
        )
      end
    end
  end

  describe '#new_device_submit' do
    describe 'successfully created a new device' do
      let(:form_attributes) do
        { 'id' => 'abc',
          'title' => 'device',
          'description' => 'test'
        }
      end
      let(:form_params) { { device: form_attributes } }
      it 'return device data in json response' do
        post :new_device_submit, params: form_params
        expect(JSON.parse(response.body)).to include_json(
          status: 'OK',
          message: 'New device created',
          work: {
            title: 'device',
            description: 'test'
          }
        )
      end
    end

    describe 'failed to create a new device' do
      let(:form_params) { { device: {} } } # no form attribute will throw an exception
      it 'return failure status in json response' do
        post :new_device_submit, params: form_params

        expect(JSON.parse(response.body)).to include_json(
          status: 'FAIL',
          message: "There is a problem creating the device. Exception: NoMethodError, undefined method `[]' for nil:NilClass",
          work: {}
        )
      end
    end
  end


  describe '#new_processing_event_submit' do
    describe 'successfully created a new processing_event' do
      let(:form_attributes) do
        { 'id' => 'abc',
          'title' => 'test processing event'
        }
      end
      let(:form_params) { { processing_event: form_attributes } }
      it 'return processing_event data in json response' do
        post :new_processing_event_submit, params: form_params
        expect(JSON.parse(response.body)).to include_json(
          status: 'OK',
          message: 'New processing_event created',
          work: {
            title: 'Processing Event (No Event Date)'
          }
        )
      end
      context 'with a child media' do
        let(:media) { Media.new(id: 'child_media', title: ['child media']) }
        let(:form_params) { { processing_event: form_attributes, child_media_id: media.id} }

        before do
          allow(Media).to receive(:find).with('child_media').and_return(media)
        end

        it 'calls #new_processing_event_media_updates' do
          expect(subject).to receive(:new_processing_event_updates).with(media)
          post :new_processing_event_submit, params: form_params
        end
      end
    end

    describe 'failed to create a new processing_event' do
      let(:form_params) { { processing_event: {} } } # no form attribute will throw an exception
      it 'return failure status in json response' do
        post :new_processing_event_submit, params: form_params

        expect(JSON.parse(response.body)).to include_json(
          status: 'FAIL',
          message: "There is a problem creating the processing_event. Exception: NoMethodError, undefined method `[]' for nil:NilClass",
          work: {}
        )
      end
    end
  end

end
