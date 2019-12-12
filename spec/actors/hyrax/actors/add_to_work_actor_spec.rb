
require 'rails_helper'

RSpec.describe Hyrax::Actors::AddToWorkActor do

  let(:next_actor) { double(create: true, update: true) }
  subject { described_class.new(next_actor) }

  let(:work) { Media.new(title: ["Work Being Updated"], id: "OriginalWork") }
  let(:ability) { Ability.new(User.new) }

  let(:parent_work) { ImagingEvent.new(title: ["Example Parent Work"], id: "ParentWork") }
  let(:parent_id) { parent_work.id }

  let(:attributes) { { work_parents_attributes: { '0' => { id: parent_id, _destroy: 'false' } } } }

  let(:env) { Hyrax::Actors::Environment.new(work, ability, attributes) }

  describe '#update' do
    before do
      parent_work.ordered_members << work
      work.save!
      parent_work.save!
    end

    context "when the parent's members already include the work id" do
      it "does nothing" do
        subject.update(env)
        parent_work.reload
        expect(parent_work.ordered_members.to_a).to include(work)
      end

      context "and the _destroy flag is set" do
        let(:attributes) {{ work_parents_attributes: { '0' => { id: parent_id, _destroy: 'true' }}}}

        it "removes the work from the parent's members and the ordered members" do
          subject.update(env)
          parent_work.reload
          expect(parent_work.ordered_member_ids).not_to include(work.id)
          expect(parent_work.member_ids).not_to include(work.id)
        end
      end
    end

    context "when the parent's members do not include the work" do
      before do
        parent_work.ordered_members.delete(work)
        parent_work.members.delete(work)
        parent_work.save!
        work.reload
        work.save!
      end

      it "is added to the parent's ordered members" do
        subject.update(env)
        parent_work.reload
        expect(parent_work.ordered_member_ids).to include(work.id)
        expect(parent_work.member_ids).to include(work.id)
      end
    end
  end
end
