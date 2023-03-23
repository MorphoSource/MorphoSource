module Hyrax
  class UsersController < ApplicationController
    include Blacklight::SearchContext
    prepend_before_action :find_user, only: [:show, :make_user_active, :make_user_inactive]

    helper Hyrax::TrophyHelper

    # do not restrict json (need it for searching for users during submission/record editing)
    # only allow admins to access the /users page
    def index
      only_active = true
      if request.format == :html
        authorize! :index, ::User
        only_active = false
        @groups = Morphosource::Users::Defaults::ROLES
      end
      @users = search(params[:uq], only_active)
    end

    # Display user profile
    def show
      authenticate_user!
      user = ::User.from_url_component(params[:id])
      return redirect_to root_path, alert: "User '#{params[:id]}' does not exist" if user.nil?
      @presenter = Hyrax::UserProfilePresenter.new(user, current_ability)
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

      # TODO: this should move to a service.
      # Returns a list of users excluding the system users and guest_users
      # @param query [String] the query string
      def search(query, only_active = true)
        if current_user&.admin? && params[:group] && Morphosource::Users::Defaults::ROLES.include?(params[:group])
          users = ::User.all.joins(:roles).where(:roles => { name: params[:group] }).distinct
        else
          users = ::User
        end

        clause = query.blank? ? nil : "%" + query.downcase + "%"
        base = users.where(*base_query)
        base = base.where("email like lower(?) OR lower(display_name) like lower(?)", clause, clause) if clause.present?
        base = base.where(active: true) if only_active
        base = base.registered
            .where("#{Hydra.config.user_key_field} not in (?)",
                   [::User.batch_user_key, ::User.audit_user_key])
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
        sort = params[:sort].blank? ? "name" : params[:sort]
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

      # only admins may use this (otherwise json route too open)
      def per_page_param
        ( current_user&.admin? && params[:per_page] ) ? params[:per_page] : 10
      end
  end
end
