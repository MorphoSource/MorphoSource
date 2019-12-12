module Morphosource
  class WorkIndexer < Hyrax::WorkIndexer

    def generate_solr_document
      super.tap do |solr_doc|
        solr_doc[Solrizer.solr_name('title', :stored_sortable)] = object.title.first
      end
    end

  end
end
