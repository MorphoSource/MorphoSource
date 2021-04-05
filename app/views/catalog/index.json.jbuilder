json.response do
  json.set! @document_type.pluralize, @presenter.documents
  json.facets @presenter.search_facets_as_json
  json.pages @presenter.pagination_info
end