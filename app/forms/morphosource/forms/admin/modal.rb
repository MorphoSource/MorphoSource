module Morphosource
  module Forms
    module Admin
      class Modal < Morphosource::Forms::Admin::Appearance
        # extend ActiveModel::Naming

       SETTINGS = %w[sitewide_modal_frequency
                     sitewide_modal_template
                     sitewide_modal_title
                     sitewide_modal_body
                     guilt_trip_template
                     guilt_trip_title
                     guilt_trip_body].freeze

        # defines a method to retrieve content block value for each setting
        define_methods

        # redefine sitewide_modal_body and guilt_trip_body to return a new rich text object
        def sitewide_modal_body
          rich_text_for(:sitewide_modal_body, nil)
        end

        def guilt_trip_body
          rich_text_for(:guilt_trip_body, nil)
        end

        def modal_templates
          files = Dir.glob("app/views/application/modals/*")
          files.map do |file|
            file_name = File.basename(file, ".html.erb").split("_").drop(1).join("_")
          end
        end

        def modal_frequencies
          [["never", 0]] + (1..10).map { |i| ["#{i * 10}%", i / 10.0] }
        end

      end
    end
  end
end