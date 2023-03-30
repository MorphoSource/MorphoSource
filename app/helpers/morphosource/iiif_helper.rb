# Patterned on Hyrax::IiifHelper, which exists in Hyrax 3.5
# frozen_string_literal: true
module Morphosource
  module IiifHelper
    def universal_viewer_base_url
      "#{request&.base_url}/uv/uv.html"
    end

    def universal_viewer_config_url
      "#{request&.base_url}/uv/uv-config.json"
    end

    def universal_viewer_config_url_front_page
      "#{request&.base_url}/uv/uv-config-front-page.json"
    end
  end
end