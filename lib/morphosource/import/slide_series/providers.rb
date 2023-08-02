module Morphosource
  module Import
    module SlideSeries
      module Providers
        extend ActiveSupport::Concern

        delegate :providers, to: :class

        class_methods do
          def providers
            @providers ||= YAML.load_file('config/import/slides/providers.yml') || {}
          end

          # see providers.yml
          def provider_methods
            %w[agreement_uri
              default_device
              fileset_accessibility
              filter_slides
              license
              list_visibility
              morphosource_use_agreement_type
              normalize_permissions
              permits_3d_use
              permits_commercial_use
              preview_mode
              publication_status
              publisher
              required_archival_of_published_derivatives
              rights_holder
              rights_statement
              visibility]
          end

          # ex: calling agreement_uri returns provider['agreement_uri']
          def define_provider_methods
            provider_methods.each do |method|
              define_method(method) { provider[method.to_s] }
            end
          end
        end

        def download_reviewer
          @download_reviewer ||= User.find_by(ms_id: provider['download_reviewer'])
        end

        def manager
          @manager ||= User.find_by(ms_id: provider['manager'])
        end

        def detect_provider(publishing_org_key)
          providers.detect { |provider| provider['publishing_org_key'] == publishing_org_key }
        end

      end
    end
  end
end