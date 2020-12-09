module Hyrax
  class DashboardController < ApplicationController
    before_action :authenticate_user!

    def show
      if can? :read, :admin_dashboard
        redirect_to main_app.my_media_index_path
      else
        redirect_to main_app.my_cart_path 
      end
    end
  end
end
