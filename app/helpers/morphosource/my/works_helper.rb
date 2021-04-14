module Morphosource
  module My
    module WorksHelper
      def active_tab?(tab)
        @tab == tab ? 'active' : ''
      end
    end
  end
end
