module Morphosource
  class SexFieldService < QaSelectService
    def initialize(_authority_name = nil)
      super('sex')
    end
  end
end
