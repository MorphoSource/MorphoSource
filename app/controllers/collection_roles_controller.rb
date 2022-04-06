# frozen_string_literal: true

# Adds/removes users to default collection managers/depositors/viewers roles.
# Used by Collection/edit#sharing for Teams and Projects
class CollectionRolesController < ApplicationController
  include Hyrax::CollectionsControllerBehavior
  include Morphosource::Dashboard::CollectionsControllerBehavior

  before_action { collection_role_values(params[:collection_roles]) }

  def update_collection_groups
    return unless can? :edit, collection

    if users_are_eligible?
      update_subcollections
      byebug
      update_agent_access
      byebug
    else
      byebug
      update_notice('user_status')
    end
    byebug
    reload_collection_share
  end

  private

  # Team/Project:
  # users are eligible if they are being removed from a role, are being added to a downloader or viewer role, or have contributor status.
  # List:
  # all registered users are eligible.
  def users_are_eligible?
    if @remove || @collection.list?
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
    redirect_to collection_members_path(collection)
  end

  def update_user_access
    byebug
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

  def change_groups(user)
    byebug
    @group.users.delete(user)
    add_user_to_group(user, @new_group)
    @new_group.save
  end

  # Add user to appropriate role if user does not already have another collection role.
  def add_user_to_group(user, group)
    byebug
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
      emails = @non_contributors.join(', ')
      flash[:error] = "#{'User'.pluralize(@non_contributors.count)} (#{emails}) can't be added to the roles manager, editor, or depositor because they do not have contributor status. Either add the #{'user'.pluralize(@non_contributors.count)} to a membership role that does not require contributor status (downloader, viewer), or have the #{'user'.pluralize(@non_contributors.count)} request contributor status."
    when 'duplicate'
      flash[:error] = "#{@user.name} is already a member of #{@collection.title.first}"
    end
  end

  def group(access)
    collection.try("#{access}_group")
  end

  # CollectionsControllerBehavior methods
  def find_subcollections
    byebug
    presenter
    member_subcollections
  end

  def presenter
    if @collection.list?
      self.presenter_class = Morphosource::MediaListPresenter
      self.single_item_search_builder_class = Morphosource::MediaLists::SingleMediaListSearchBuilder
    end
    super
  end
end
