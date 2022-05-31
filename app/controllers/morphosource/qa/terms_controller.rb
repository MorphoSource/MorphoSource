
module Morphosource
  module Qa
    class TermsController < ::Qa::TermsController

      private

        def init_authority
          @authority = authority_by_facet
        end

        def authority_by_facet
          case params["facet"]
          when "attributes"
            ::Morphosource::Qa::Authorities::Getty::AAT::Attributes.new
          when "materials"
            ::Morphosource::Qa::Authorities::Getty::AAT::Materials.new
          when "periods"
            ::Morphosource::Qa::Authorities::Getty::AAT::Periods.new
          when "types"
            ::Morphosource::Qa::Authorities::Getty::AAT::Types.new
          else
            ::Qa::Authorities::Getty::AAT.new
          end
        end
    end
  end
end
