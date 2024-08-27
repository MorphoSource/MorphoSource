class GlobusFileSubmittersController < ApplicationController

  prepend_before_action :find_user

  def make_globus_file_submitter
    return unless current_user.admin?

    @user.make_globus_file_submitter
    flash[:info] = "globus File Submitter access has been granted"
    redirect_to hyrax.user_path(@user)
  end

  def remove_globus_file_submitter
    return unless current_user.admin?

    @user.remove_globus_file_submitter
    flash[:info] = "globus File Submitter access has been removed"
    redirect_to hyrax.user_path(@user)
  end

  private

    def find_user
      @user = ::User.from_url_component(params[:id])
      redirect_to root_path, alert: "User '#{params[:id]}' does not exist" if @user.nil?
    end
end
