module Morphosource
  class DeviceMediaSearchService < Morphosource::PhysicalObjectMediaSearchService

    self.list_search_builder_class = Morphosource::DeviceMediaSearchBuilder

  end
end
