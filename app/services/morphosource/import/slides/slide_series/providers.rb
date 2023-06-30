module Morphosource
  module Import
    module Slides
      module SlideSeries
        module Providers
          extend ActiveSupport::Concern

          delegate :providers, to: :class

          class_methods do
            def providers
              @providers ||= YAML.load_file('config/import/slides/providers.yml') || {}
            end

            def provider_array_methods
              %w[agreement_uri fileset_accessibility license morphosource_use_agreement_type preview_mode permits_3d_use publisher required_archival_of_published_derivatives rights_holder rights_statement]
            end

            def provider_string_methods
              %w[filter_slides list_visibility publication_status visibility]
            end
          end

          def related_url
            eval("#{@json}#{provider['related_url']}")
          end

          def provider
            @provider ||= providers[organization.id]
          end

          def download_reviewer
            @download_reviewer ||= User.find_by(ms_id: provider['download_reviewer'])
          end

          def manager
            @manager ||= User.find_by(ms_id: provider['manager'])
          end

        end
      end
    end
  end
end