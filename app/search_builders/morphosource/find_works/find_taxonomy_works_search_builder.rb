module Morphosource
  module FindWorks
    class FindTaxonomyWorksSearchBuilder < Morphosource::FindWorksSearchBuilder
      def models
        [Taxonomy, TaxonomyResource]
      end
    end
  end
end