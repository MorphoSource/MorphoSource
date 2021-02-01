module Hyrax
  class DashboardController < ApplicationController
    before_action :authenticate_user!

    def show
      if current_user.contributor? or current_user.admin?
        redirect_to main_app.my_projects_path
      else
        redirect_to main_app.my_cart_path 
      end
    end
  end
end
