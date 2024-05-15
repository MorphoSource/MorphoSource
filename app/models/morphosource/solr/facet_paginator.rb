# frozen_string_literal: true
module Morphosource
  module Solr
    class FacetPaginator < ::Blacklight::Solr::FacetPaginator
      mattr_accessor :request_keys do
        { sort: :'facet.sort', page: :'facet.page', prefix: :'facet.prefix', contains: :'facet.contains' }
      end
    end
  end
end
