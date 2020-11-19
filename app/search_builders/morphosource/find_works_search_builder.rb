module Morphosource
  class FindWorksSearchBuilder < Hyrax::My::FindWorksSearchBuilder

    self.default_processor_chain -= [ :show_only_resources_deposited_by_current_user ]

    def models
      if types = self.scope.params[:type]
        types.map(&:constantize)
      else
        super
      end
    end

    # override Hydra::AccessControlsEnforcement to include 'read'
    def discovery_permissions
      @discovery_permissions ||= ["edit","read"]
    end
  end
end