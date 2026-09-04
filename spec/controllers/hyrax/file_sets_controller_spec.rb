require 'rails_helper'

RSpec.describe Hyrax::FileSetsController, type: :controller do
  routes { Hyrax::Engine.routes }

  let(:user) { create(:user) }

  # A Hyrax::FileSet resolved from an unmigrated legacy ::FileSet is Wings-wrapped:
  # it still presents as a genuine Hyrax::Resource, which is exactly the trap
  # `case file_set; when Hyrax::Resource` fell into.
  let(:af_file_set) { create(:file_set, user: user) }
  let(:wings_backed_file_set) { Hyrax.query_service.find_by(id: af_file_set.id) }

  let(:migrated_file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, user: user) }

  describe '#valkyrie_native?' do
    it 'is false for a plain AF ::FileSet' do
      expect(controller.send(:valkyrie_native?, af_file_set)).to be false
    end

    it 'is false for a Wings-wrapped unmigrated FileSet, even though it is a Hyrax::Resource' do
      expect(wings_backed_file_set).to be_a(Hyrax::Resource)
      expect(controller.send(:valkyrie_native?, wings_backed_file_set)).to be false
    end

    it 'is true for a genuinely migrated Hyrax::FileSet' do
      expect(controller.send(:valkyrie_native?, migrated_file_set)).to be true
    end
  end

  describe '#delete' do
    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    it 'routes a Wings-wrapped unmigrated FileSet to the AF actor, not the Valkyrie transaction' do
      actor = instance_double(Hyrax::Actors::FileSetActor, destroy: true)
      allow(controller).to receive(:actor).and_return(actor)
      expect(controller).not_to receive(:unlink_valkyrie_file_set_from_af_work)
      expect(controller.send(:transactions)).not_to receive(:[])

      controller.send(:delete, file_set: wings_backed_file_set)

      expect(actor).to have_received(:destroy)
    end

    it 'routes a genuinely migrated FileSet through the Valkyrie destroy transaction' do
      allow(controller).to receive(:curation_concern).and_return(migrated_file_set)
      allow(controller).to receive(:unlink_valkyrie_file_set_from_af_work)
      transaction = instance_double(Hyrax::Transactions::Transaction)
      allow(controller.send(:transactions)).to receive(:[]).with('file_set.destroy').and_return(transaction)
      allow(transaction).to receive(:with_step_args).and_return(transaction)
      allow(transaction).to receive(:call).and_return(double('result', value!: migrated_file_set))
      expect(controller).not_to receive(:actor)

      controller.send(:delete, file_set: migrated_file_set)

      expect(controller).to have_received(:unlink_valkyrie_file_set_from_af_work).with(migrated_file_set)
    end
  end

  describe '#af_file_set' do
    it 'resolves the real ::FileSet for a Wings-wrapped unmigrated FileSet' do
      allow(controller).to receive(:file_set).and_return(wings_backed_file_set)
      resolved = controller.send(:af_file_set)
      expect(resolved).to be_a(::FileSet)
      expect(resolved.id).to eq af_file_set.id
    end

    it 'returns a plain AF ::FileSet as-is, without an extra lookup' do
      allow(controller).to receive(:file_set).and_return(af_file_set)
      expect(::FileSet).not_to receive(:find)
      expect(controller.send(:af_file_set)).to equal(af_file_set)
    end
  end

  describe '#parent' do
    # Regression test: ArResourceParentship#parent/#member_of only see AF parents
    # via valkyrie_member_ids_ssim, which stays empty until a FileSet is actually
    # migrated -- calling it on the Wings-wrapped resource itself (as an earlier
    # version of this method did) always returned nil for a real, attached,
    # unmigrated FileSet, crashing `redirect_to [main_app, parent]` downstream.
    it 'finds the real AF parent Media for a Wings-wrapped unmigrated FileSet that is actually attached' do
      media = create(:media)
      media.ordered_members << af_file_set
      media.save!

      allow(controller).to receive(:file_set).and_return(wings_backed_file_set)

      expect(controller.send(:parent).id).to eq media.id
    end

    it 'reads member_of for a genuinely migrated FileSet' do
      allow(controller).to receive(:file_set).and_return(migrated_file_set)
      expect(migrated_file_set).to receive(:member_of).and_call_original
      controller.send(:parent)
    end
  end

  describe '#actor' do
    it 'builds Hyrax::Actors::FileSetActor with the real ::FileSet, not the Wings-wrapped resource' do
      allow(controller).to receive(:file_set).and_return(wings_backed_file_set)
      allow(controller).to receive(:current_user).and_return(user)

      expect(Hyrax::Actors::FileSetActor).to receive(:new).with(instance_of(::FileSet), user).and_call_original

      controller.send(:actor)
    end
  end
end
