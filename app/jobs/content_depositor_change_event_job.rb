# Log work depositor change to activity streams
#
# @attr [Boolean] reset (false) should the access controls be reset. This means revoking edit access from the depositor
class ContentDepositorChangeEventJob < ContentEventJob
  include Rails.application.routes.url_helpers
  include ActionDispatch::Routing::PolymorphicRoutes

  attr_accessor :reset

  # @param [ActiveFedora::Base] work the work to be transfered
  # @param [User] user the user the work is being transfered to.
  # @param [TrueClass,FalseClass] reset (false) if true, reset the access controls. This revokes edit access from the depositor
  def perform(work, user, reset = false, sending_user = nil)
    @reset = reset
    @new_owner = select_user(user)
    @sending_user = select_user(sending_user)
    super(work, user)
  end

  def select_user(user)
    return user if user.is_a?(User)

    User.find_by(id: user) || SolrDocument.where({"id" => user}).first
  end

  def action
    "User #{link_to_profile @sending_user} has transferred #{link_to_work work.title.first} to user #{link_to_profile @new_owner}"
  end

  def link_to_work(text)
    link_to text, polymorphic_path(work)
  end

  # Log the event to the work's stream
  def log_work_event(work)
    work.log_event(event)
  end
  alias log_file_set_event log_work_event

  def work
    @work ||= Morphosource::ChangeContentOwnerService.call(repo_object, @new_owner, reset)
  end

  # overriding default to log the event to the depositor instead of their profile
  def log_user_event(owner)
    # log the event to the proxy depositor's profile if sending user is a User (and not an org collection)
    if @sending_user.present? && @sending_user.is_a?(User)
      @sending_user.log_profile_event(event)
    end
    if @new_owner.is_a? User
      @new_owner.log_event(event)
    end
  end
end
