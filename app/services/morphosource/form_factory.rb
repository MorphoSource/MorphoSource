module Morphosource
  class FormFactory < Hyrax::FormFactory
    def initialize(controller = nil)
#      @controller = controller
      super()
    end

    def build(model, ability, controller)
      form = super(model, ability, controller)
      form.controller = controller if form.respond_to?(:controller=)
      form
    end
  end
end