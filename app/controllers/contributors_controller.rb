class ContributorsController < ApplicationController

  prepend_before_action :find_user

  def make_contributor
    return unless current_user.admin?

    @user.make_contributor
    redirect_to hyrax.user_path(@user)
  end

  def remove_contributor
    return unless current_user.admin?

    @user.remove_contributor
    redirect_to hyrax.user_path(@user)
  end

  private

    def find_user
      @user = ::User.from_url_component(params[:id])
      redirect_to root_path, alert: "User '#{params[:id]}' does not exist" if @user.nil?
    end
end
