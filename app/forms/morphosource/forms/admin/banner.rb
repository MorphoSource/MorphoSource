module Morphosource
  module Forms
    module Admin
      class Banner < Morphosource::Forms::Admin::Appearance
        extend ActiveModel::Naming

        SETTINGS = %w[sitewide_banner
                      sitewide_banner_text].freeze

        # defines a method to retrieve content block value for each setting
        define_methods

        # redefine sitewide_banner_text to return a rich text object
        # this allows for editing as html in the rich text editor
        # banner text is stored as a contnent block
        def sitewide_banner_text
          banner_text = block_for(:sitewide_banner_text, nil)
          ActionText::RichText.new(record_id: 'banner_text', record_type: 'Banner', body: banner_text)
        end
      end
    end
  end
end