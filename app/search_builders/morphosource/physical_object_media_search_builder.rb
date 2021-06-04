module Morphosource
  class PhysicalObjectMediaSearchBuilder < ::SearchBuilder
    include Hyrax::FilterByType
    attr_reader :object_id

    class_attribute :object_id_field
    self.object_id_field = 'physical_object_id_ssim'

    self.default_processor_chain += [:represents_object]

    def initialize(scope:,
                   object_id:)
      @object_id = object_id
      super(scope)
    end

    def represents_object(solr_parameters)
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << "#{object_id_field}:#{object_id}"
    end

    # This overrides the models in FilterByType
    def models
      [Media]
    end

    # Overrides Hydra::AccessControlsEnforcement
    def discovery_permissions
       ["edit","download","read"]
    end
  end
end
