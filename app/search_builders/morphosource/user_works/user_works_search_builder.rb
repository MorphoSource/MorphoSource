module Morphosource
  module UserWorks
    class UserWorksSearchBuilder < Hyrax::SearchBuilder

      self.default_processor_chain = [:filter_models]

    end
  end
end
