# frozen_string_literal: true
module Hyrax
  # Overrides of methods defined by the Blacklight gem.
  module BlacklightOverride
    def application_name
      Hyrax.config.site_title
    end
  end
end
