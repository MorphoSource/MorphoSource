
require 'rails_helper'

RSpec.describe Hyrax::Actors::DeviceActor do

  let(:device)          { Device.new(title: ["Device"], organization_id: [] ) }
  let(:user)            { FactoryBot.create(:contributor) }
  let(:ability)         { Ability.new(user) }
  let(:env)             { Hyrax::Actors::Environment.new(device, ability, attributes) }

  let(:org_work)        { FactoryBot.create(:organization, title: ["Organization Work"] ) }
  let(:org_collection)  { FactoryBot.create(:organization_collection, title: ["Organization Collection"], depositor: user.ms_id ) }

  describe '#create' do

    context 'adding the device to an organization work' do
      let(:attributes)  { { work_parents_attributes: { '0' => { id: org_work.id, _destroy: 'false' } } } }

      it 'adds the organization as a parent' do
        expect {
          Hyrax::CurationConcern.actor.create(env)
        }.to change { device.in_works }.from([]).to([org_work])
         .and change { device.organization_id }.from([]).to([org_work.id])
      end
    end

    context 'adding the device to an organization collection' do
      let(:attributes)  { { work_parents_attributes: { '0' => { id: org_collection.id, _destroy: 'false' } } } }

      it 'does not add the organization as a parent' do
        expect {
          Hyrax::CurationConcern.actor.create(env)
        }.to not_change { device.in_works }
         .and not_change { device.member_of_collections.to_a }
         .and change { device.organization_id }.from([]).to([org_collection.id])
      end
    end
  end

  describe 'update' do
    context 'removing the device from an organization work' do
      let(:attributes)  { { work_parents_attributes: { '0' => { id: org_work.id, _destroy: 'true' } } } }

      before do
        org_work.ordered_members << device
        org_work.save!
        device.organization_id = [org_work.id]
        device.save!
      end

      it 'removes the organization as a parent' do
        expect {
          Hyrax::CurationConcern.actor.update(env)
        }.to change { device.in_works }.from([org_work]).to([])
         .and change { device.organization_id }.from([org_work.id]).to([])
      end
    end

    context 'removing the device from an organization collection' do
      let(:attributes)  { { work_parents_attributes: { '0' => { id: org_collection.id, _destroy: 'true' } } } }

      before do
        device.organization_id = [org_collection.id]
        device.save!
      end

      it 'removes the organization from the device' do
        expect {
          Hyrax::CurationConcern.actor.update(env)
        }.to change { device.organization_id }.from([org_collection.id]).to([])
      end
    end
    # test that edge cases will still process correctly
    context 'adding/removing multiple org works and collections' do
      let(:org_work2)       { FactoryBot.create(:organization, title: ['Organization Work 2']) }
      let(:org_collection2) { FactoryBot.create(:organization_collection, depositor: user.ms_id) }

      # remove org_work and org_collection, add org_work2 and org_collection2
      let(:attributes)      { { work_parents_attributes: { '0' => { id: org_work.id, _destroy: 'true' }, '1' => { id: org_collection.id, _destroy: 'true' }, '2' => { id: org_work2.id, _destroy: 'false' }, '3' => { id: org_collection2.id, _destroy: 'false' } } } }

      before do
        org_work.ordered_members << device
        org_work.save!
        device.organization_id = [org_work.id, org_collection.id]
        device.save!
      end

      it 'adds and removes organizations from the device' do
        expect {
          Hyrax::CurationConcern.actor.update(env)
        }.to change { device.organization_id }.from(match_array([org_work.id, org_collection.id])).to(match_array([org_work2.id, org_collection2.id]))
         .and change { device.in_works }.from([org_work]).to([org_work2])
      end
    end
  end
end
