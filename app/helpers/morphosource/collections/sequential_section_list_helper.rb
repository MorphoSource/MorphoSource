module Morphosource
  module Collections
    module SequentialSectionListHelper
      include Morphosource::CollectionHelper

      def link_to_specimen(id)
        return unless id.present?

        specimen = SolrDocument.find(id)
        title = specimen.title.first
        taxonomy = specimen.taxonomies_titles&.first
        link_to(specimen_showcase_path(specimen)) do
          "#{title} <em>#{taxonomy}</em>".html_safe
        end
      end

    end
  end
end