# Generated via
#  `rails generate hyrax:work CulturalHeritageObject`
require 'rails_helper'

RSpec.describe Hyrax::CulturalHeritageObjectsController do
  it 'has curation_concern_type ::CulturalHeritageObject' do
    expect(described_class.curation_concern_type).to be(::CulturalHeritageObject)
  end

  it 'has show_presenter Hyrax::BiologicalSpecimenPresenter' do
    expect(described_class.show_presenter).to be(Hyrax::CulturalHeritageObjectPresenter)
  end

  describe '#showcase' do
    let(:public_cho)  { CulturalHeritageObject.create(title: ['public cho'], visibility: 'open', vouchered: ['Yes']) }
    let(:private_cho) { CulturalHeritageObject.create(title: ['private cho'], visibility: 'restricted', vouchered: ['Yes']) }
    let(:user)        { User.create(email: 'email@example.com', password: 'password') }

    context 'user is not signed in' do
      context 'work is public' do
        it 'is authorized' do
          get :showcase, params: { id: public_cho.id }
          expect(response.status).to eq(200)
        end
      end
      context 'work is private' do
        it 'is redirects to sign in' do
          get :showcase, params: { id: private_cho.id }
          expect(response.status).to eq(302)
        end
      end
    end
    context 'user is signed in' do
      before do
        sign_in user
      end
      context 'work is public' do
        it 'is authorized' do
          get :showcase, params: { id: public_cho.id }
          expect(response.status).to eq(200)
        end
      end
      context 'work is private' do
        it 'is unauthorized' do
          get :showcase, params: { id: private_cho.id }
          expect(response.status).to eq(401)
        end
      end
    end
  end
end
