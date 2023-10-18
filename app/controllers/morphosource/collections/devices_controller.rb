module Morphosource
  module Collections
    class DevicesController < Morphosource::CollectionsController

      # restrict to admins
      before_action :authorize_admin

    end
  end
end