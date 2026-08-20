# Generated via
#  `rails generate hyrax:work Organization`
require 'rails_helper'

RSpec.describe Hyrax::OrganizationsController, type: :controller do
  it "should have curation_concern_type ::Organization" do
    expect(Hyrax::OrganizationsController.curation_concern_type).to be(::Organization)
  end

  it "should have show_presenter Hyrax::OrganizationPresenter" do
    expect(Hyrax::OrganizationsController.show_presenter).to be(Hyrax::WorkShowPresenter)
  end

  describe '#unlinked_organizations' do
    let(:team)                  { Collection.create(title: ['team'], collection_type_gid: team_collection_type.to_global_id) }
    let(:user)                  { User.create(email: 'user@email.com', password: 'password') }
    let(:org1)                  { Organization.create(title: ['green yellow']) }
    let(:org4)                  { Organization.create(title: ['red yellow'], team_id: ['456']) }
    let(:org2)                  { Organization.create(title: ['black']) }
    let(:org3)                  { Organization.create(title: ['blue'], team_id: [team.id]) }

    before do
      ActiveFedora::SolrService.add(org1.to_solr, commit: true)
      ActiveFedora::SolrService.add(org2.to_solr, commit: true)
      ActiveFedora::SolrService.add(org3.to_solr, commit: true)
      sign_in user
    end

    context 'user is not an admin' do
      let(:params)  { { uq: 'yel' } }
      it 'does not return any organizations' do
        get :unlinked_organizations, format: :json, params: params
        expect(controller.instance_variable_get(:@orgs)).to be_nil
      end
    end

    context 'user is an admin' do
      let(:params)      { { uq: '' } }
      let(:admin_role)  { Role.create(name: 'admin') }
      before do
        admin_role.users << user
        admin_role.save
        get :unlinked_organizations, format: :json, params: params
      end

      it 'renders the show page' do
        expect(response).to render_template("hyrax/organizations/unlinked_organizations")
      end

      context 'user searches for bl' do
        let(:params)  { { uq: 'bl' } }

        it 'returns unlinked organizations with a title that begins with bl' do
          expect(controller.instance_variable_get(:@orgs).map{|o| o["title_tesim"]}).to match_array([org2.title])
        end
      end
      context 'user searches for ye' do
        let(:params)  { { uq: 'ye' } }

        it 'returns unlinked organizations with a title that includes ye' do
          expect(controller.instance_variable_get(:@orgs).map{|o| o["title_tesim"]}).to match_array([org1.title])
        end
      end
    end
  end

  describe '#destroy' do
    let(:organization) { Organization.create(title: ['organization']) }
    let(:user)          { User.create(email: 'email@email.com', password: 'password', ms_id: 'user') }

    before do
      allow(subject).to receive(:authorize!).with(:destroy, organization).and_return(true)
      sign_in user
    end

    context 'when the destroy is not halted' do
      it 'destroys the organization' do
        delete :destroy, params: { id: organization.id }
        expect(Organization.exists?(organization.id)).to be false
      end
    end

    context 'when the destroy is halted and populates errors' do
      before do
        allow_any_instance_of(Organization).to receive(:destroy) do |record|
          record.errors.add(:base, 'boom')
          false
        end
      end

      it 'does not destroy the organization and redirects with the error instead of a silent 204' do
        delete :destroy, params: { id: organization.id }
        expect(response).to have_http_status(:found)
        expect(flash[:alert]).to eq('boom')
        # .exists? is Solr-backed; CleanupFileSetsActor deletes the Solr doc before
        # the model-level destroy runs, so .find (reads Fedora directly) is what
        # actually proves the record survived.
        expect { Organization.find(organization.id) }.not_to raise_error
      end

      it 'renders an unprocessable_entity json response' do
        delete :destroy, params: { id: organization.id, format: :json }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when the destroy is halted without populating errors' do
      before do
        allow_any_instance_of(Organization).to receive(:destroy).and_return(false)
      end

      it 'falls back to a generic unable-to-delete message' do
        delete :destroy, params: { id: organization.id }
        expect(flash[:alert]).to match(/\AUnable to delete .*organization\.\z/)
      end
    end
  end
end
