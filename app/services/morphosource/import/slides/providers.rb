module Morphosource
  module Import
    module Providers

      delegate :providers, to: class

      def self.providers
        @providers ||= YAML.load_file('config/import/slides/providers.yml') || {}
      end

      def provider
        @provider ||= providers[organization.id]
      end

      def agreement_uri
        Array(provider['agreement_uri'])
      end

      def download_reviewer
        @download_reviewer ||= User.find(provider['download_reviewer'])
      end

      def fileset_accessibility
        Array(provider['fileset_accessibility'])
      end

      def license
        Array(provider['license'])
      end

      def list_visibility
        Array(provider['list_visibility'])
      end

      def manager
        @manager ||= User.find(provider['manager'])
      end

      def morphosource_use_agreement_type
        Array(provider['morphosource_use_agreement_type'])
      end

      def preview_mode
        Array(provider['preview_mode'])
      end

      def publication_status
        provider['publication_status']
      end

      def permits_3d_use
        Array(provider['permis_3d_use'])
      end

      def publisher
        Array(provider['publisher'])
      end

      def required_archival_of_published_derivatives
        Array(provider['required_archival_of_published_derivatives'])
      end

      def rights_holder
        Array(provider['rights_holder'])
      end

      def rights_statement
        Array(provider['rights_statement'])
      end

      def visibility
        Array(provider['visibility'])
      end















    end
  end
end