require 'rails_helper'

RSpec.describe Hyrax::PropagateChangeDepositorJob do
  let(:job) { described_class.new }
  let(:user) { instance_double(User, user_key: 'new-owner') }
  let(:source_id) { 'abc123' }

  context 'when a Valkyrie resource exists' do
    let(:resource) { instance_double(Valkyrie::Resource) }
    let(:file_set) { instance_double('ValkyrieFileSet') }
    let(:acl) { instance_double('Acl') }
    let(:permission_manager) { instance_double('PermissionManager', acl: acl) }

    it 'updates each child file set via Valkyrie services' do
      allow(Hyrax.query_service).to receive(:find_by).with(id: source_id).and_return(resource)
      allow(Hyrax.custom_queries).to receive(:find_child_file_sets).with(resource: resource).and_return([file_set])
      allow(Hyrax.persister).to receive(:save)

      allow(file_set).to receive(:permission_manager).and_return(permission_manager)
      allow(file_set).to receive(:depositor=)
      allow(acl).to receive(:permissions=)
      allow(acl).to receive(:save)
      allow(acl).to receive(:grant).with(:edit).and_return(acl)
      allow(acl).to receive(:to).with(user).and_return(acl)
      allow(User).to receive(:find_by_user_key).with('new-owner').and_return(user)

      job.perform(source_id, user, true)

      expect(acl).to have_received(:permissions=).with([])
      expect(Hyrax.persister).to have_received(:save).with(resource: file_set)
    end

    it 'does not clear ACL permissions when reset is false' do
      allow(Hyrax.query_service).to receive(:find_by).with(id: source_id).and_return(resource)
      allow(Hyrax.custom_queries).to receive(:find_child_file_sets).with(resource: resource).and_return([file_set])
      allow(Hyrax.persister).to receive(:save)

      allow(file_set).to receive(:permission_manager).and_return(permission_manager)
      allow(file_set).to receive(:depositor=)
      allow(acl).to receive(:permissions=)
      allow(acl).to receive(:save)
      allow(acl).to receive(:grant).with(:edit).and_return(acl)
      allow(acl).to receive(:to).with(user).and_return(acl)
      allow(User).to receive(:find_by_user_key).with('new-owner').and_return(user)

      job.perform(source_id, user, false)

      expect(acl).not_to have_received(:permissions=)
      expect(Hyrax.persister).to have_received(:save).with(resource: file_set)
    end
  end

  context 'when Valkyrie cannot find the source work' do
    let(:af_file_set) { instance_double('FileSet') }
    let(:af_work) { instance_double('Media', file_sets: [af_file_set]) }

    it 'falls back to ActiveFedora file sets' do
      allow(Hyrax.query_service).to receive(:find_by)
        .with(id: source_id)
        .and_raise(Valkyrie::Persistence::ObjectNotFoundError)

      allow(ActiveFedora::Base).to receive(:exists?).with(source_id).and_return(true)
      allow(ActiveFedora::Base).to receive(:find).with(source_id).and_return(af_work)

      allow(af_file_set).to receive(:permissions=)
      allow(af_file_set).to receive(:apply_depositor_metadata)
      allow(af_file_set).to receive(:save!)

      job.perform(source_id, user, true)

      expect(af_file_set).to have_received(:permissions=).with([])
      expect(af_file_set).to have_received(:apply_depositor_metadata).with(user)
      expect(af_file_set).to have_received(:save!)
    end

    it 'no-ops when the work does not exist in ActiveFedora either' do
      allow(Hyrax.query_service).to receive(:find_by)
        .with(id: source_id)
        .and_raise(Valkyrie::Persistence::ObjectNotFoundError)
      allow(ActiveFedora::Base).to receive(:exists?).with(source_id).and_return(false)
      allow(ActiveFedora::Base).to receive(:find)

      expect { job.perform(source_id, user, false) }.not_to raise_error
      expect(ActiveFedora::Base).not_to have_received(:find)
    end
  end
end
