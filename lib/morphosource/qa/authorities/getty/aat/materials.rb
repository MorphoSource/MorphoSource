module Morphosource
  module Qa
    module Authorities
      module Getty
        class AAT
          class Materials < Morphosource::Qa::Authorities::Getty::AAT

            # http://vocab.getty.edu/page/aat/300264091
            def sparql(q)
              @facet_id = 300264091
              super
            end

          end
        end
      end
    end
  end
end
