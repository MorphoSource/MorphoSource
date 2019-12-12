module Morphosource
    module FileSetDerivatives
      extend ActiveSupport::Concern
      include Hyrax::FileSet::Derivatives

      private

        def file_set_derivatives_service
          Morphosource::MsDerivativeService.for(self)
        end
    end
end
