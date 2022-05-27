module Morphosource
  module Qa::Authorities
    class Getty::AAT::Periods < Morphosource::Qa::Authorities::Getty::AAT

      # http://vocab.getty.edu/page/aat/300264088
      def sparql(q)
        @facet_id = 300264088
        super
      end

    end
  end
end
