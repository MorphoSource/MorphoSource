require 'rails_helper'

RSpec.describe SubmissionsController, type: :controller do

  let(:user)          { FactoryBot.create(:user) }
  let(:contributors)  { Role.create(name: 'contributor') }

  before do
    contributors.users << user
    contributors.save
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

      it 'returns JSON organization response' do
        allow(subject).to receive(:find_ancestor_organization).and_return(double("Organization",
          :title => ['Test Title'],
          :download_reviewer => ['012345'],
          :agreement_uri => ['http://agreement.uri'],
          :license => ['CC0'],
          :rights_statement => ['In Copyright'],
          :terms_of_use => ['Terms'],
          :permits_commercial_use => [true],
          :permits_3d_use => [false],
          :rights_holder => ['Name: Fname, Type: Copyright'],
          :funding => ['Funder'],
          :publisher => ['Publisher'],
          :cite_as => ['Citation'],
          :download_permission => ['restricted_download']
        ))

        post :organization_default_media_fields, params: form_params

        expect(JSON.parse(response.body)).to include_json(
          status: 'OK',
          message: 'Organization default permission settings retrieved',
          default_fields: {
          'download_reviewer': ['012345'],
          'agreement_uri': ['http://agreement.uri'],
          'license': ['CC0'],
          'rights_statement': ['In Copyright'],
          'terms_of_use': ['Terms'],
          'permits_commercial_use': [true],
          'permits_3d_use': [false],
          'rights_holder': ['Name: Fname, Type: Copyright'],
          'funding': ['Funder'],
          'publisher': ['Publisher'],
          'cite_as': ['Citation']
          },
          organization_alert_message: 'This value has been suggested by Test Title',
          organization_title: ['Test Title']
        )
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
