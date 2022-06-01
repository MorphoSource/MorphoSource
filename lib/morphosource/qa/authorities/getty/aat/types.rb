module Morphosource
  module Qa::Authorities
    class Getty::AAT::Types < Morphosource::Qa::Authorities::Getty::AAT

      # http://vocab.getty.edu/page/aat/300264092
      def sparql(q)
        @facet_id = 300264092
        super
      end

    end
  end
end
