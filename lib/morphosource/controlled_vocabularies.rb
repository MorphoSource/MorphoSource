# frozen_string_literal: true
module Morphosource
  module ControlledVocabularies
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Aat
      autoload :Tgn
      autoload :ResourceLabelCaching
    end
  end
end
