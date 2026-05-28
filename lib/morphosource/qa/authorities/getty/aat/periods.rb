module Morphosource
  module Qa
    module Authorities
      module Getty
        class AAT
          class Periods < Morphosource::Qa::Authorities::Getty::AAT

            # http://vocab.getty.edu/page/aat/300264088
            def sparql(q)
              @facet_id = 300264088
              super
            end

          end
        end
      end
    end
  end
end
