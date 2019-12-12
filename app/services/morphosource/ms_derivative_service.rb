module Morphosource
  # Responsible for creating and cleaning up the derivatives of a file_set with MS-specific methods
  class MsDerivativeService < Hyrax::DerivativeService
    class_attribute :services
    self.services = [Morphosource::MsFileSetDerivativesService]
  end
end
