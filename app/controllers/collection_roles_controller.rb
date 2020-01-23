# frozen_string_literal: true

# Adds/removes users to default collection managers/depositors/viewers roles.
# Used by Collection/edit#sharing for Teams and Projects
class CollectionRolesController < ApplicationController
  include Hyrax::CollectionsControllerBehavior

  before_action { collection_role_values(params[:collection_roles]) }

  def update_collection_groups
    return unless can? :edit, collection

    update_subcollections
    update_agent_access
    reload_collection_share
  end

  private

  def update_subcollections
    find_subcollections
    update_child_groups unless @subcollection_docs.empty?
    reset_collection_role_values
  end

  def update_child_groups
    @parent = @collection
    child_ids = @subcollection_docs.map(&:id)
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
    redirect_to(hyrax.edit_dashboard_collection_path(collection.id, anchor: 'sharing'))
  end

  def update_user_access
    if @new_group
      change_groups(user)
    elsif @remove
      @group.users.delete(user)
    else
      check_subcollection_for_user(user) if @parent
      add_user_to_group(user, @group)
    end
    update_notice('success') if @group.save
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
      flash[:alert] = translate('hyrax.dashboard.collections.form.permission_update_errors')
    end
  end

  def group(access)
    collection.try("#{access}_group")
  end

  # CollectionsControllerBehavior methods
  def find_subcollections
    presenter
    member_subcollections
  end
end
