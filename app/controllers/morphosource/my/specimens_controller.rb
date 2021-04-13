module Morphosource
  module My
    class SpecimensController < WorksController
      include SpecimensControllerBehavior

      def index
        super
      end

      private

      def save_tab
        @tab = :specimens
      end

    end
  end
end
