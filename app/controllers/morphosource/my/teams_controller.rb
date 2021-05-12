module Morphosource
  module My
    class TeamsController < Morphosource::My::CollectionsController

      # instance_name: :collection

      def index
        super
      end

      def new
        byebug
        super
      end

    end
  end
end
