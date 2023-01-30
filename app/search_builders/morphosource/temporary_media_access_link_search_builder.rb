module Morphosource
  class TemporaryMediaAccessLinkSearchBuilder < Hyrax::SearchBuilder
    include Hyrax::SingleResult
    self.default_processor_chain = [:find_one]
  end
end