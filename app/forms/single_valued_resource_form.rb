# Similar to SingleValuedForm, enabling resource forms to have single valued forms but multi-valued fields.

module SingleValuedResourceForm
  extend ActiveSupport::Concern
  included do
    # Override this in inheriting classes to customize behavior
    def single_valued_terms
      primary_terms + secondary_terms
    end

    def multiple?(field)
      if single_valued_terms.include?(field.to_sym)
        false
      else
        super
      end
    end

    def [](key)
      return Array(super).first if single_valued_terms.include?(key.to_sym)
      super
    end
  end
end
