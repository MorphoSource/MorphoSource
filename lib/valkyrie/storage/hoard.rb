# frozen_string_literal: true

module Valkyrie
  module Storage
    # Hybrid storage adapter that combines multiple Valkyrie storage adapters.
    # Inspired by the FreyjaWithWings pattern for metadata adapters.
    #
    # Routes operations to the appropriate service based on which adapter
    # handles the given ID format. The first service is the "primary" and
    # is used as a fallback for uploads when no service matches the filename.
    class Hoard
      attr_reader :services

      # @param services [Array<#handles?, #find_by, #upload, #delete>]
      #   Array of storage adapter instances. First is the primary adapter.
      def initialize(services:)
        @services = services
      end

      # @return the primary (first) storage adapter
      def primary_service
        services.first
      end

      # @param id [Valkyrie::ID]
      # @return [Boolean] true if ANY service handles the ID
      def handles?(id:)
        services.any? { |service| service.handles?(id: id) }
      end

      # Delegates to the primary service.
      # @param feature [Symbol]
      # @return [Boolean]
      def supports?(feature)
        primary_service.supports?(feature)
      end

      # @return [String] protocol of the primary service
      def protocol
        primary_service.protocol
      end

      # Find the file by delegating to the service that handles the ID.
      #
      # @param id [Valkyrie::ID]
      # @return [Valkyrie::StorageAdapter::File]
      # @raise [Valkyrie::StorageAdapter::FileNotFound]
      def find_by(id:)
        service_for(id: id).find_by(id: id)
      end

      # Upload by routing to the service that handles the ID format.
      # Uses original_filename to determine which service handles URLs vs local files.
      # Falls back to the primary service if no service matches.
      #
      # @param file [IO]
      # @param original_filename [String]
      # @param resource [Valkyrie::Resource]
      # @return [Valkyrie::StorageAdapter::File]
      def upload(file:, original_filename:, resource: nil, **extra)
        service = services.find { |s| s.handles?(id: Valkyrie::ID.new(original_filename.to_s)) } || primary_service
        service.upload(file: file, original_filename: original_filename, resource: resource, **extra)
      end

      # Upload a new version, delegating to the service that handles the ID.
      #
      # @param id [Valkyrie::ID]
      # @param file [IO]
      # @return [Valkyrie::StorageAdapter::File]
      def upload_version(id:, file:)
        service_for(id: id).upload_version(id: id, file: file)
      end

      # Find all versions, delegating to the service that handles the ID.
      #
      # @param id [Valkyrie::ID]
      # @return [Array<Valkyrie::StorageAdapter::File>]
      def find_versions(id:)
        service_for(id: id).find_versions(id: id)
      end

      # Delete the file, delegating to the service that handles the ID.
      #
      # @param id [Valkyrie::ID]
      def delete(id:)
        service_for(id: id).delete(id: id)
      end

      private

      # Find the service that handles the given ID.
      # @param id [Valkyrie::ID]
      # @return [Object] the storage adapter service
      # @raise [Valkyrie::StorageAdapter::FileNotFound] if no service handles it
      def service_for(id:)
        service = services.find { |s| s.handles?(id: id) }
        raise Valkyrie::StorageAdapter::FileNotFound, "No storage service handles id: #{id}" unless service
        service
      end
    end
  end
end
