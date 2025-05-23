module Morphosource
  module Forms
    module Admin
      class Banner < Morphosource::Forms::Admin::Appearance

        SETTINGS = %w[sitewide_banner
                      sitewide_banner_text].freeze

        def sitewide_banner
          block_for(:sitewide_banner, nil)
        end

        def sitewide_banner_text
          rich_text_for(:sitewide_banner_text, nil)
        end
      end
    end
  end
end