module Morphosource
  module Dashboard
    class TeamsController < Morphosource::Dashboard::CollectionsController

      before_action :helphelp

      # def self.cancan_resource_class
      #   Collection
      # end

      load_and_authorize_resource :class => "::Collection"

      # skip_load_and_authorize_resource :only => :new

      # authorize_resource only: [:new], class: Collection, instance_name: :collection

      # authorize_resource :class => "Collection"

      # load_and_authorize_resource :class => "Collection", :parent => false, instance_name: :collection

      # load_and_authorize_resource :collection, :class => "Collection", :parent => false

      def helphelp
        byebug
      end


      def new
        byebug
        super
      end

      def edit
        byebug
        super
      end

    end
  end
end
