module Morphosource
  extend ActiveSupport::Autoload

  autoload :Configurable
  autoload :Derivatives

  include Morphosource::Configurable

  VERSION = '2.0a'.freeze

  module Works
    extend ActiveSupport::Autoload

    autoload :Base
    autoload :MimeTypes
  end
end
