module Qa::Authorities
  # Find collections including Projects, Teams, Media Lists, and Sequential Section Lists
  class FindCollections < Qa::Authorities::Collections
    self.search_builder_class = Morphosource::My::CollectionSearchBuilder
  end
end