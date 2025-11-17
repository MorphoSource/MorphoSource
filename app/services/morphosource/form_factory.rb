# Override Hyrax::FormFactory to pass the controller to the form
module Morphosource
  class FormFactory < Hyrax::FormFactory
    def initialize(controller = nil)
      super()
    end

    def build(model, ability, controller)
      form = super(model, ability, controller)
      form.controller = controller if form.respond_to?(:controller=)
      form
    end
  end
end