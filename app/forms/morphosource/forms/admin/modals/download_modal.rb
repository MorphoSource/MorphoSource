module Morphosource
  module Forms
    module Admin
      module Modals
        class DownloadModal < Morphosource::Forms::Admin::Modal
          # extend ActiveModel::Naming
          include Rails.application.routes.url_helpers


          # settings listed here get saved as content blocks
          SETTINGS = %w[download_modal_frequency
                      download_modal_template
                      download_modal_title
                      download_modal_body
                      download_guilt_trip_template
                      download_guilt_trip_title
                      download_guilt_trip_body].freeze

          # defines a method to retrieve content block value for each setting
          define_methods

          # redefine download_modal_body and guilt_trip_body to return a new rich text object
          def download_modal_body
            rich_text_for(:download_modal_body, nil)
          end

          def download_guilt_trip_body
            rich_text_for(:download_guilt_trip_body, nil)
          end

          alias modal_frequency download_modal_frequency
          alias modal_template download_modal_template
          alias modal_title download_modal_title
          alias modal_body download_modal_body
          alias guilt_trip_template download_guilt_trip_template
          alias guilt_trip_title download_guilt_trip_title
          alias guilt_trip_body download_guilt_trip_body

          def dash_case_name
            form_name.dasherize
          end
        end
      end
    end
  end
end