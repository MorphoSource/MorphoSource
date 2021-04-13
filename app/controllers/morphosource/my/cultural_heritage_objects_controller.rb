module Morphosource
  module My
    class CulturalHeritageObjectsController < WorksController

      def index
        super
      end

      private

      def save_tab
        @tab = :chos
      end

    end
  end
end
