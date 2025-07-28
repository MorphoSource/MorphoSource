require 'rails_helper'

# frozen_string_literal: true
RSpec.describe Morphosource::Collections::MediaSearchBuilder do
  let(:user)          { User.create(email: 'registered@email.com', password: 'password') }
  let(:ability)       { ::Ability.new(user) }
  let(:scope)         { double('scope', blacklight_config: CatalogController.blacklight_config, current_ability: ability, params: {}) }

  subject { described_class.new(scope: scope, collection: collection) }


  describe 'member_of_collection' do
    let(:organization)  { double('organization', id: 'organization_id') }

    context 'collection is an unlinked team' do
      let(:collection)  { double('collection', id: 'collection_id', team?: true, organization: nil) }
      context 'with a child project' do
        before do
          allow(subject).to receive(:subcollection_ids).and_return(['child_project_id'])
        end
        it 'searches for team and project media' do
          expect(subject.member_of_collection({})).to eq(["(member_of_collection_ids_ssim:(collection_id OR child_project_id))"])
        end
      end
      context 'without a child project' do
        before do
          allow(subject).to receive(:subcollection_ids).and_return([])
        end
        it 'searches for team media only' do
          expect(subject.member_of_collection({})).to eq(["(member_of_collection_ids_ssim:(collection_id))"])
        end
      end
    end
    context 'collection is a linked team' do
      let(:collection)    { double('collection', id: 'collection_id', team?: true, organization: organization) }

      context 'with a child project' do
        before do
          allow(subject).to receive(:subcollection_ids).and_return(['child_project_id'])
        end
        it 'searches for team, organization, and project media' do
          expect(subject.member_of_collection({})).to eq(["(member_of_collection_ids_ssim:(collection_id OR child_project_id) OR media_organization_id_ssim:organization_id)"])
        end
      end

      context 'without a child project' do
        before do
          allow(subject).to receive(:subcollection_ids).and_return([])
        end
        it 'searches for team and organization media only' do
          expect(subject.member_of_collection({})).to eq(["(member_of_collection_ids_ssim:(collection_id) OR media_organization_id_ssim:organization_id)"])
        end
      end
    end

    context 'collection is a project' do
      let(:collection)    { double('collection', id: 'collection_id', team?: false, organization: nil, organization_collection?: false) }

      it 'searches for project media only' do
        expect(subject.member_of_collection({})).to eq(["(member_of_collection_ids_ssim:(collection_id))"])
      end
    end

    context 'collection is a child project of a linked team' do
      # collection.organization returns parent team's organization
      let(:collection)    { double('collection', id: 'collection_id', team?: false, organization_collection?: false, organization: organization) }

      it 'searches for project media only' do
        expect(subject.member_of_collection({})).to eq(["(member_of_collection_ids_ssim:(collection_id))"])
      end
    end
  end
end
