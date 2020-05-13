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
