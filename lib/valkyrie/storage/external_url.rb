# frozen_string_literal: true

require 'http'
require 'digest'
require 'fileutils'
require 'stringio'

module Valkyrie
  module Storage
    # Read-only Valkyrie storage adapter for external HTTP/HTTPS URLs.
    # Files exist at remote URLs; find_by wraps them in a lazy IO that
    # streams file content to a local cache on first access, avoiding
    # holding large files in memory.
    # Upload is a no-op that registers the URL as the file identifier.
    class ExternalUrl
      PROTOCOLS = %w[http:// https://].freeze

      def protocol
        'https://'
      end

      # @param id [Valkyrie::ID]
      # @return [Boolean] true if the ID starts with http:// or https://
      def handles?(id:)
        id_str = id.to_s
        PROTOCOLS.any? { |p| id_str.start_with?(p) }
      end

      # @param _feature [Symbol]
      # @return [Boolean] always false
      def supports?(_feature)
        false
      end

      # Returns an ExternalFile wrapping a lazy IO that defers the HTTP request.
      # On first access, the remote file is streamed chunk-by-chunk to a
      # local cache under Hyrax.config.working_external_path. If a cached
      # copy already exists, it is reused without re-downloading.
      #
      # @param id [Valkyrie::ID] the URL to fetch
      # @return [Valkyrie::StorageAdapter::ExternalFile]
      def find_by(id:)
        url = id.to_s
        io = LazyHTTPFile.new(url, Hyrax.config.remote_request_headers)
        Valkyrie::StorageAdapter::ExternalFile.new(
          id: Valkyrie::ID.new(url),
          io: io
        )
      end

      # No-op upload -- returns an ExternalFile whose ID is the given URL.
      # The file already exists at the external URL; no data is transferred.
      #
      # @param file [IO] ignored
      # @param original_filename [String] the external URL
      # @param resource [Valkyrie::Resource]
      # @return [Valkyrie::StorageAdapter::ExternalFile]
      def upload(file:, original_filename:, resource: nil, **_extra)
        find_by(id: Valkyrie::ID.new(original_filename.to_s))
      end

      # No-op version upload
      def upload_version(id:, file:)
        find_by(id: id)
      end

      # No-op delete -- cannot delete external URLs
      def delete(id:)
        # intentional no-op
      end

      # No versions for external files
      def find_versions(id:)
        []
      end

      # Lazy IO wrapper that defers the HTTP GET until content is accessed.
      # On first access, streams the remote file chunk-by-chunk to a local
      # cache file under Hyrax.config.working_external_path. If a cached
      # copy already exists on disk, it is reused without re-downloading.
      # Delegates read/rewind/size/close/path to the underlying file handle.
      class LazyHTTPFile
        def initialize(url, headers = {})
          @url = url
          @headers = headers
        end

        def read(*args)
          _inner_io.read(*args)
        end

        def rewind
          _inner_io.rewind
        end

        def size
          ensure_downloaded!
          ::File.size(local_path)
        end

        def close
          @_inner_io&.close
        end

        def path
          ensure_downloaded!
          local_path
        end

        private

        # @return [File] an open file handle to the local cached copy
        def _inner_io
          @_inner_io ||= begin
            ensure_downloaded!
            ::File.open(local_path, 'rb')
          end
        end

        # Downloads the remote file to the local cache if not already present.
        def ensure_downloaded!
          return if ::File.exist?(local_path)
          download_to_local_path
        end

        # Streams the remote file chunk-by-chunk to the local cache path.
        def download_to_local_path
          FileUtils.mkdir_p(::File.dirname(local_path))
          response = HTTP.headers(@headers).follow.get(@url)
          unless response.status.success?
            raise Valkyrie::StorageAdapter::FileNotFound,
                  "HTTP #{response.status} for #{@url}"
          end
          ::File.open(local_path, 'wb') do |f|
            while (chunk = response.body.readpartial)
              f.write(chunk)
            end
          end
        rescue HTTP::Error, HTTP::TimeoutError => e
          # Clean up partial download
          FileUtils.rm_f(local_path)
          raise Valkyrie::StorageAdapter::FileNotFound,
                "Failed to fetch #{@url}: #{e.message}"
        end

        # Deterministic local cache path based on a SHA256 hash of the URL,
        # preserving the original file extension.
        # @return [String]
        def local_path
          @local_path ||= begin
            digest = Digest::SHA256.hexdigest(@url)
            ext = ::File.extname(URI.parse(@url).path)
            ::File.join(Hyrax.config.working_external_path, "#{digest}#{ext}")
          end
        end
      end
    end
  end

  # File subclass for external URL-backed files, allowing callers to
  # distinguish them from local files without inspecting the ID protocol.
  #
  #   file.is_a?(Valkyrie::StorageAdapter::ExternalFile) # => true
  #   file.external? # => true
  #
  class StorageAdapter::ExternalFile < StorageAdapter::File
    def external?
      true
    end
  end
end
