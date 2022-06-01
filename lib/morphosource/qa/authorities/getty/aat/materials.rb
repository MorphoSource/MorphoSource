module Morphosource
  module Qa::Authorities
    class Getty::AAT::Materials < Morphosource::Qa::Authorities::Getty::AAT

      # http://vocab.getty.edu/page/aat/300264091
      def sparql(q)
        @facet_id = 300264091
        super
      end

    end
  end
end
