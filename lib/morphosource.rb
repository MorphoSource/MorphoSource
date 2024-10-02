module Morphosource
  extend ActiveSupport::Autoload

  autoload :Configurable
  autoload :CrossrefDoiMinter
  autoload :Derivatives
  autoload :Gbif
  autoload :IDigBio
  autoload :Metadata
  autoload :Minter
  autoload :PackratApi
  autoload :ResqueJobsHelper
  autoload :ZipDeflate64

  include Morphosource::Configurable

  # The Minter code must be loaded after initialization, otherwise it will
  # sometimes race with configuration variables being set correctly
  Rails.configuration.after_initialize do
    include Morphosource::Minter
  end

  VERSION = '2.0a'.freeze

  module Works
    extend ActiveSupport::Autoload

    autoload :Base
    autoload :FileSetCharacterizationParentUpdateService
    autoload :IndexRelatedWorks
    autoload :MimeTypes
  end
end
