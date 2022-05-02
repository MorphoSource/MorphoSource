module Morphosource
  class TargetTypesService < QaSelectService
    def initialize(_authority_name = nil)
      super('target_types')
    end
  end
end
