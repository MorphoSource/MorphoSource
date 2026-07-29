# frozen_string_literal: true

# Adds/removes users to default collection managers/depositors/viewers roles.
# Used by Collection/edit#sharing for Teams and Projects
class CollectionRolesController < ApplicationController
  include Hyrax::CollectionsControllerBehavior
  include Morphosource::Dashboard::CollectionsControllerBehavior

  before_action { collection_role_values(params[:collection_roles]) }

  delegate :presenter_class, to: :@collection

  def update_collection_groups
    return unless can? :edit, collection
    if users_are_eligible?
      if last_manager_update_forbidden?
        update_notice('last_manager')
      else
        update_subcollections
        update_agent_access
        update_collection_managed_date
      end
    else
      update_notice('user_status')
    end
    reload_collection_share
  end

  private

  # users are eligible if they are being removed from a role, are being added to a downloader or viewer role, or have contributor status.
  def users_are_eligible?
    if @remove
      return true
    elsif @collection.list?
      return true
    elsif group_is_downloader_or_viewer?
      return true
    elsif users_are_contributors?
      return true
    else
      false
    end
  end

  # if user is being added or moved to a downlower or viewer role, return true
  def group_is_downloader_or_viewer?
    access = params[:collection_roles][:access]
    new_access = params[:collection_roles][:new_access]
    roles = ['downloaders', 'viewers']
    if new_access
      roles.include? new_access
    else
      roles.include? access
    end
  end

  # return true if all users have contributor status, otherwise return false and add any non_contributor emails to @non_contributors
  def users_are_contributors?
    @non_contributors = []
    if user?
      return true if user.contributor?
      @non_contributors << user.email
    elsif group?
      return true if group_members_are_contributors?
    end
    false
  end

  def group_members_are_contributors?
    @non_contributors = []
    team.group_members.each do |member|
      @non_contributors << member.email if !member.contributor?
    end
    @non_contributors.empty?
  end

  def update_subcollections
    find_subcollections
    update_child_groups unless @subcollection_docs.empty?
    reset_collection_role_values
  end

  def update_child_groups
    @parent = @collection
    child_ids = @subcollection_docs.map { |doc| doc['id'] }
    child_ids.each do |id|
      update_child_collection(id)
    end
  end

  def update_child_collection(id)
    @collection = Collection.find(id)
    collection_role_values(params[:collection_roles])
    update_agent_access
  end

  def reset_collection_role_values
    @collection = @parent
    collection_role_values(params[:collection_roles])
  end

  def update_agent_access
    update_user_access if user?
    add_group_access if group?
  end

  def reload_collection_share
    redirect_to helpers.members_tab_url(collection)
  end

  def update_user_access
    if @new_group || @remove
      if @new_group
        change_groups(user)
      elsif @remove
        @group.users.delete(user)
      end
      update_notice('success') if @group.save
    else
      check_subcollection_for_user(user) if @parent
      if collection.group_members.include? user
        update_notice('duplicate')
      else
        add_user_to_group(user, @group)
        update_notice('success') if @group.save
      end
    end
  end

  # The single enforcement point for the last-manager rule: preflight the parent
  # and every affected subcollection before changing any role, so a rejected
  # parent update cannot partially change its child projects. Nothing downstream
  # re-checks, so this must run before any role is written.
  def last_manager_update_forbidden?
    return false unless manager_role_change?
    return true if removing_last_manager_from?(collection) && last_manager_locked?(collection)

    subcollection_docs.any? do |doc|
      child = Collection.find(doc['id'])
      removing_last_manager_from?(child) && last_manager_locked?(child)
    end
  end

  # Only meaningful before the child walk reassigns @group, which is why the
  # preflight is its sole caller. The presence check keeps a collection with no
  # role groups from matching on nil == nil.
  def manager_role_change?
    managers_group = collection.managers_group
    managers_group.present? && @group == managers_group && (@remove || @new_group.present?)
  end

  # Counts people rather than memberships: nothing stops a user being added to a
  # role group twice, and a duplicated sole manager would otherwise inflate the
  # count past the guard and let the last manager be removed.
  def removing_last_manager_from?(candidate)
    managers_group = candidate.managers_group
    managers_group.present? &&
      managers_group.users.include?(user) &&
      managers_group.users.distinct.count < 2
  end

  # Organizations must always retain at least one manager (even admins cannot
  # remove the last one) so org-mode download-reviewer resolution always has a
  # target. Teams and Projects keep the existing admin override.
  def last_manager_locked?(candidate)
    candidate.organization_collection? || !current_user.admin?
  end

  def change_groups(user)
    @group.users.delete(user)
    add_user_to_group(user, @new_group)
    @new_group.save
  end

  # Add user to appropriate role if user does not already have another collection role.
  def add_user_to_group(user, group)
    group.users << user unless collection.group_members.include? user
  end

  # If a user is added to a team, and the team's subcollection already has that user in a role, remove the user.
  def check_subcollection_for_user(user)
    return unless @collection.group_members.include? user

    @collection.user_groups.each do |group|
      group.users.delete(user)
      group.save
    end
  end

  # Add all team members to chosen role unless member already has a collection role.
  def add_group_access
    return unless can? :edit, team

    update_subcollections_membership if @parent
    team.group_members.each do |member|
      add_user_to_group(member, @group)
    end
    update_notice('success') if @group.save
  end

  def update_subcollections_membership
    ids = @subcollection_docs.map(&:id)
    copy_team_members_to_subcollections(ids)
    reset_collection_role_values
  end

  def copy_team_members_to_subcollections(collection_ids)
    collection_ids.each do |id|
      @collection = Collection.find(id)
      collection_role_values(params[:collection_roles])
      copy_team_members
      @group.save
    end
  end

  def copy_team_members
    team.group_members.each do |member|
      check_subcollection_for_user(member)
      add_user_to_group(member, @group)
    end
  end

  def user?
    @agent_type == 'user'
  end

  def group?
    @agent_type == 'group'
  end

  def collection_role_values(params)
    @agent_type = params[:agent_type]
    @remove = params[:new_access] == 'remove'
    @group = group(params[:access])
    @new_group = group(params[:new_access])
    update_notice('fail')
  end

  def user
    @user ||= User.find_by(ms_id: params[:collection_roles][:agent_id])
  end

  def team
    @team ||= Collection.find(params[:collection_roles][:team_collection_id])
  end

  def collection
    @collection ||= Collection.find(params[:id])
  end

  def update_notice(status)
    flash.discard
    case status
    when 'success'
      flash[:notice] = translate('hyrax.dashboard.collections.form.permission_update_notices.participants')
    when 'fail'
      flash[:error] = translate('hyrax.dashboard.collections.form.permission_update_errors')
    when 'user_status'
      user = 'user'.pluralize(@non_contributors.count)
      emails = @non_contributors.join(', ')
      access = params[:collection_roles][:access]
      roles = t("morphosource.dashboard.collections.#{@collection.collection_type.machine_id}.members.roles.non-contributor")
      flash[:error] = translate('morphosource.dashboard.collections.form.non_contributor_errors', user: user, emails: emails, access: access, roles: roles)
    when 'last_manager'
      flash[:error] = "Cannot remove the last manager from this collection."
    when 'duplicate'
      flash[:error] = "#{@user.name} is already a member of #{@collection.title.first}"
    end
  end

  def group(access)
    collection.try("#{access}_group")
  end

  # CollectionsControllerBehavior methods
  def find_subcollections
    presenter
    subcollection_docs
  end

  # The collection's immediate children. Memoized because the last-manager
  # preflight and the child role update both need them within one request.
  def subcollection_docs
    @subcollection_docs ||=
      Morphosource::SolrService.new.get_docs("has_model_ssim:Collection AND member_of_collection_ids_ssim:#{collection.id}")
  end

  def update_collection_managed_date
    organization = @collection.organization || @collection
    return unless organization.organization? || organization.organization_collection?

    organization.record_date_managed
    organization.save! if organization.date_managed_changed?
  end
end
