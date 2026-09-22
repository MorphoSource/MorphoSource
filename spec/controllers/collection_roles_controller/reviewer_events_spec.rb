# frozen_string_literal: true

require 'rails_helper'

# Manager membership is a Postgres join, so an OrganizationCollection after_update never
# sees it; this controller is the publish site for that half of the event.
RSpec.describe CollectionRolesController, type: :controller do
  include TestHelpers

  let(:manager)       { FactoryBot.create(:contributor) }
  let(:another_user)  { FactoryBot.create(:contributor) }
  let(:second_manager) { FactoryBot.create(:contributor) }

  let(:organization) { FactoryBot.create(:organization_collection, depositor: manager.ms_id) }
  let(:team)         { FactoryBot.create(:team, title: ['Team'], depositor: manager.ms_id) }
  let(:project)      { FactoryBot.create(:project, title: ['Project'], depositor: manager.ms_id) }

  let(:reviewer_event) { 'organization.reviewers.updated' }

  before do
    sign_in manager
    allow(Hyrax.publisher).to receive(:publish).and_call_original
  end

  def add_manager(collection, user)
    { collection_roles: { agent_type: 'user', remove: 'false', access: 'managers', agent_id: user.ms_id },
      id: collection.id }
  end

  def expect_no_reviewer_event
    expect(Hyrax.publisher).not_to have_received(:publish).with(reviewer_event, anything)
  end

  context 'on an OrganizationCollection' do
    before do
      organization.managers_group.users << manager
      organization.managers_group.save
      allow(subject).to receive(:can?).with(:edit, organization).and_return(true)
      allow(subject).to receive(:update_subcollections).and_return(true)
    end

    it 'publishes one event when a Manager is added' do
      post :update_collection_groups, params: add_manager(organization, another_user)

      expect(organization.managers).to include(another_user)
      expect(Hyrax.publisher).to have_received(:publish)
        .with(reviewer_event, organization_id: organization.id).once
    end

    it 'publishes one event when a Manager is removed' do
      organization.managers_group.users << another_user
      organization.managers_group.save

      params = { collection_roles: { agent_type: 'user', new_access: 'remove', access: 'managers', agent_id: another_user.ms_id },
                 id: organization.id }
      post :update_collection_groups, params: params

      expect(organization.managers).not_to include(another_user)
      expect(Hyrax.publisher).to have_received(:publish)
        .with(reviewer_event, organization_id: organization.id).once
    end

    # date_managed does not move here, so nothing is saved or reindexed.
    it 'publishes exactly one event when a Manager is swapped for another role' do
      organization.managers_group.users << second_manager
      organization.managers_group.save

      params = { collection_roles: { agent_type: 'user', new_access: 'depositors', access: 'managers', agent_id: second_manager.ms_id },
                 id: organization.id }
      post :update_collection_groups, params: params

      expect(organization.managers).not_to include(second_manager)
      expect(organization.depositors).to include(second_manager)
      expect(Hyrax.publisher).to have_received(:publish)
        .with(reviewer_event, organization_id: organization.id).once
    end

    it 'publishes nothing for a non-Manager role change' do
      params = { collection_roles: { agent_type: 'user', remove: 'false', access: 'depositors', agent_id: another_user.ms_id },
                 id: organization.id }
      post :update_collection_groups, params: params

      expect(organization.depositors).to include(another_user)
      expect_no_reviewer_event
    end

    it 'publishes nothing when the user already holds a role and nothing is mutated' do
      organization.viewers_group.users << another_user
      organization.viewers_group.save

      post :update_collection_groups, params: add_manager(organization, another_user)

      expect(organization.managers).not_to include(another_user)
      expect_no_reviewer_event
    end

    # An after_action would be skipped here, and a retried edit is a no-op that publishes nothing.
    it 'still publishes when the action raises after the role mutation committed' do
      allow(subject).to receive(:update_collection_managed_date).and_raise(ActiveFedora::RecordInvalid.new(organization))

      expect { post :update_collection_groups, params: add_manager(organization, another_user) }
        .to raise_error(ActiveFedora::RecordInvalid)

      expect(organization.managers).to include(another_user)
      expect(Hyrax.publisher).to have_received(:publish)
        .with(reviewer_event, organization_id: organization.id).once
    end

    # Raising would mask the action's own exception; losing the event is the recorded decision.
    it 'does not fail the request when the publish itself raises' do
      allow(Hyrax.publisher).to receive(:publish)
        .with(reviewer_event, anything).and_raise(Redis::CannotConnectError)

      expect { post :update_collection_groups, params: add_manager(organization, another_user) }
        .not_to raise_error

      expect(organization.managers).to include(another_user)
    end

    # Rails.logger.error alone is invisible in Sentry: active_support_logger is not a
    # configured breadcrumbs_logger, so a lost event would go unnoticed.
    it 'reports a failed publish to Sentry' do
      allow(Sentry).to receive(:capture_exception)
      allow(Hyrax.publisher).to receive(:publish)
        .with(reviewer_event, anything).and_raise(Redis::CannotConnectError)

      post :update_collection_groups, params: add_manager(organization, another_user)

      expect(Sentry).to have_received(:capture_exception)
        .with(instance_of(Redis::CannotConnectError), extra: { organization_id: organization.id })
    end
  end

  context 'on a Team' do
    before do
      team.create_collection_groups
      allow(subject).to receive(:can?).with(:edit, team).and_return(true)
      allow(subject).to receive(:update_subcollections).and_return(true)
    end

    it 'publishes nothing when a Manager is added' do
      post :update_collection_groups, params: add_manager(team, another_user)

      expect(team.managers).to include(another_user)
      expect_no_reviewer_event
    end
  end

  context 'on a Project' do
    before do
      project.create_collection_groups
      allow(subject).to receive(:can?).with(:edit, project).and_return(true)
      allow(subject).to receive(:update_subcollections).and_return(true)
    end

    it 'publishes nothing when a Manager is added' do
      post :update_collection_groups, params: add_manager(project, another_user)

      expect(project.managers).to include(another_user)
      expect_no_reviewer_event
    end
  end

  # note_manager_role_change fires once per team member; the Set collapses them to one event.
  context 'when a Team is added to an OrganizationCollection managers role' do
    let(:source_team) { FactoryBot.create(:team, title: ['Source'], depositor: manager.ms_id) }
    let(:project_a)   { FactoryBot.create(:project, title: ['Project_A'], depositor: manager.ms_id) }
    let(:project_b)   { FactoryBot.create(:project, title: ['Project_B'], depositor: manager.ms_id) }

    let(:projects_solr) { [SolrDocument.new(project_a.to_solr), SolrDocument.new(project_b.to_solr)] }

    let(:params) do
      { collection_roles: { agent_type: 'group', access: 'managers', team_collection_id: source_team.id },
        id: organization.id }
    end

    before do
      organization.managers_group.users << manager
      organization.managers_group.save
      project_a.create_collection_groups
      project_b.create_collection_groups
      source_team.create_collection_groups
      source_team.managers_group.users << another_user
      source_team.managers_group.users << second_manager
      source_team.managers_group.save
      allow(subject).to receive(:can?).with(:edit, organization).and_return(true)
      allow(subject).to receive(:can?).with(:edit, source_team).and_return(true)
      allow(subject).to receive(:find_subcollections).and_return(true)
      subject.instance_variable_set(:@subcollection_docs, projects_solr)
    end

    it 'publishes one event for the OrganizationCollection and none for its Projects' do
      post :update_collection_groups, params: params

      expect(organization.managers).to include(another_user, second_manager)
      expect(Hyrax.publisher).to have_received(:publish)
        .with(reviewer_event, organization_id: organization.id).once
      expect(Hyrax.publisher).not_to have_received(:publish)
        .with(reviewer_event, organization_id: project_a.id)
      expect(Hyrax.publisher).not_to have_received(:publish)
        .with(reviewer_event, organization_id: project_b.id)
    end
  end
end
