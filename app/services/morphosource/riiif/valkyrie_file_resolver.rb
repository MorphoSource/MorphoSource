# frozen_string_literal: true

module Morphosource
  module Riiif
    # Riiif file resolver that handles Valkyrie files (storage adapter) as well as
    # legacy AF files (Fedora/HTTP storage). A file is Valkyrie if its FileMetadata is in
    # Postgres, whatever the FileSet id format (migrated FileSets keep 9-digit ids);
    # everything else delegates to the fallback HTTP resolver.
    class ValkyrieFileResolver
      UUID_REGEX = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i

      def initialize(fallback_resolver:)
        @fallback_resolver = fallback_resolver
      end

      def find(id)
        file_metadata_id_str = CGI.unescape(id).split('/')[2]
        return @fallback_resolver.find(id) unless uuid?(file_metadata_id_str)

        begin
          file_metadata = Hyrax.query_service.postgres_service.find_by(id: Valkyrie::ID.new(file_metadata_id_str))
          return @fallback_resolver.find(id) unless file_metadata.is_a?(::Hyrax::FileMetadata)

          file_identifier = file_metadata.file_identifier.to_s
          # Half-migrated FileSets: metadata in Postgres, bytes still in Fedora
          return @fallback_resolver.find(id) if file_identifier.start_with?('fedora:')

          if external_url_identifier?(file_identifier)
            return fetch_from_external_url(file_identifier)
          else
            disk_path = resolve_to_disk_path(file_metadata.file_identifier)
            return ::Riiif::File.new(disk_path) if disk_path
          end
        rescue Valkyrie::Persistence::ObjectNotFoundError
          # Not a Valkyrie file — fall through
        end

        @fallback_resolver.find(id)
      end

      private

      def uuid?(str)
        str.to_s.match?(UUID_REGEX)
      end

      def external_url_identifier?(file_identifier)
        file_identifier.start_with?('http://', 'https://')
      end

      # For ExternalUrl-backed FileSets, hand the URL directly to Riiif's HTTP
      # resolver so it fetches from the remote host (with redirect-following and
      # auth headers from the monkey-patched RemoteFile). This uses Riiif's own
      # tmp/network_files cache rather than Hyrax's working_external_path cache.
      def fetch_from_external_url(url)
        remote = ::Riiif::HttpFileResolver::RemoteFile.new(
          url,
          cache_path: @fallback_resolver.cache_path,
          basic_auth_credentials: @fallback_resolver.basic_auth_credentials
        )
        ::Riiif::File.new(remote.fetch)
      end

      def resolve_to_disk_path(file_identifier)
        file = Hyrax.storage_adapter.find_by(id: file_identifier)
        file.disk_path.to_s
      rescue Valkyrie::StorageAdapter::FileNotFound
        nil
      end
    end
  end
end
