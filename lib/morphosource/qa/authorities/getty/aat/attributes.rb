module Morphosource
  module Qa
    module Authorities
      module Getty
        class AAT
          class Attributes < Morphosource::Qa::Authorities::Getty::AAT

            # http://vocab.getty.edu/page/aat/300264087
            def sparql(q)
              @facet_id = 300264087
              super
            end

          end
        end
      end
    end
  end
end
