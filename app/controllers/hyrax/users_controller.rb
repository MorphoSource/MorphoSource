module Hyrax
  class UsersController < ApplicationController
    include Blacklight::SearchContext
    include Morphosource::RestApiBehavior

    prepend_before_action :find_user, only: [:show, :make_user_active, :make_user_inactive, :become]
    before_action :authenticate_api_key_optional, only: [:index, :show]
    before_action :require_authentication, only: [:index, :show]
    helper Hyrax::TrophyHelper

    # HTML: admin only. JSON: any authenticated user (used for submission/editing autocomplete).
    def index
      if request.format == :html
        authorize! :index, ::User
        @groups = Morphosource::Users::Defaults::ROLES
      end
      @users = search(params[:uq], false)
    end

    # HTML: any authenticated user. JSON: the user themselves or an admin.
    def show
      return redirect_to root_path, alert: "User '#{params[:id]}' does not exist" if @user.nil?
      respond_to do |format|
        format.html { @presenter = Morphosource::UserProfilePresenter.new(@user, current_ability) }
        format.json do
          return head :forbidden unless current_user == @user || current_user&.admin?
        end
      end
    end

    # For admins, allow sign in as any user
    # https://github.com/heartcombo/devise/wiki/How-To:-Sign-in-as-another-user-if-you-are-an-admin
    def become
      if current_user&.admin?
        sign_in(:user, @user)
        session[:become_user] = true
        redirect_to root_url, notice: "Signed in as user #{@user.name}."
      else
        render :file => "#{Rails.root}/public/404.html",  layout: false, status: :not_found
      end
    end

    def make_user_active
      return unless current_user.admin?

      @user.make_active
      redirect_to hyrax.user_path(@user)
    end

    def make_user_inactive
      return unless current_user.admin?

      @user.make_inactive
      redirect_to hyrax.user_path(@user)
    end

    private

      # After authenticate_api_key_optional runs, current_user is set for both session
      # and API key users. Enforce that one of those succeeded before reaching the action.
      def require_authentication
        return deny_access_unauthorized if current_user.nil? && request.format == :json
        authenticate_user!
      end

      # TODO: this should move to a service.
      # Returns a list of users excluding the system users and guest_users
      # @param query [String] the query string
      def search(query, only_active = true)
        if current_user&.admin? && params[:group] && Morphosource::Users::Defaults::ROLES.include?(params[:group])
          users = ::User.all.joins(:roles).where(:roles => { name: params[:group] }).distinct
        else
          users = ::User
        end

        search_only_active_users = only_active || (
          current_user&.admin? &&
          params[:only_active].present? &&
          params[:only_active] == 'true'
        )

        clause = query.blank? ? nil : "%" + query.downcase + "%"
        base = users.where(*base_query)
        base = base.where("email like lower(?) OR lower(display_name) like lower(?)", clause, clause) if clause.present?
        base = base.where(active: true) if search_only_active_users
        base = base.registered
            .where("#{Hydra.config.user_key_field} not in (?)",
                   [::User.system_user_key, ::User.batch_user_key, ::User.audit_user_key])
            .references(:trophies)
            .order(sort_value)
            .page(params[:page] || 1).per(per_page_param)

        return base
      end

      # You can override base_query to return a list of arguments
      def base_query
        [nil]
      end

      def find_user
        @user = ::User.from_url_component(params[:id])
        redirect_to root_path, alert: "User '#{params[:id]}' does not exist" if @user.nil?
      end

      def sort_value
        sort = params[:sort].blank? ? default_sort : params[:sort]
        case sort
        when 'name'
          'display_name'
        when 'name desc'
          'display_name DESC'
        when 'login'
          Hydra.config.user_key_field
        when 'login desc'
          "#{Hydra.config.user_key_field} DESC"
        else
          sort
        end
      end

      # If no query term is provided, default to sorting by created_at desc
      # otherwise, sort by display_name
      def default_sort
        params[:uq].blank? ? "created_at desc" : "display_name"
      end

      # only admins may use this (otherwise json route too open)
      def per_page_param
        ( current_user&.admin? && params[:per_page] ) ? params[:per_page] : 10
      end
  end
end
