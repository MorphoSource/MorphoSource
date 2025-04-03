module Qa::Authorities
  class FindCollectionsToAddMedia < Qa::Authorities::FindWorks
    self.search_builder_class = Morphosource::FindCollectionsToAddMediaSearchBuilder
  end
end