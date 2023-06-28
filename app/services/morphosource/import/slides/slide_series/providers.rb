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
              %w[list_visibility publication_status visibility]
            end
          end

          def provider
            @provider ||= providers[organization.id]
          end



          # array_methods.each do |method|
          #   define_method(method) do
          #     Array(provider[method.to_s])
          #   end
          # end



          # string_methods.each do |method|
          #   define_method(method) do
          #     provider[method.to_s]
          #   end
          # end

          # def agreement_uri
          #   Array(provider['agreement_uri'])
          # end

          def download_reviewer
            @download_reviewer ||= User.find_by(ms_id: provider['download_reviewer'])
          end

          def manager
            @manager ||= User.find_by(ms_id: provider['manager'])
          end

          # def fileset_accessibility
          #   Array(provider['fileset_accessibility'])
          # end

          # def license
          #   Array(provider['license'])
          # end

          # def list_visibility
          #   provider['list_visibility']
          # end



          # def morphosource_use_agreement_type
          #   Array(provider['morphosource_use_agreement_type'])
          # end

          # def preview_mode
          #   Array(provider['preview_mode'])
          # end

          # def publication_status
          #   provider['publication_status']
          # end

          # def permits_3d_use
          #   Array(provider['permits_3d_use'])
          # end

          # def publisher
          #   Array(provider['publisher'])
          # end

          # def required_archival_of_published_derivatives
          #   Array(provider['required_archival_of_published_derivatives'])
          # end

          # def rights_holder
          #   Array(provider['rights_holder'])
          # end

          # def rights_statement
          #   Array(provider['rights_statement'])
          # end

          # def visibility
          #   provider['visibility']
          # end

        end
      end
    end
  end
end