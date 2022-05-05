module Morphosource
  class LightSourceService < QaSelectService
    def initialize(_authority_name = nil)
      super('light_source')
    end
  end
end
