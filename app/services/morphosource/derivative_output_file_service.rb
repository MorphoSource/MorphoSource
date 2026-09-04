# frozen_string_literal: true
module Morphosource
  # Routes a derivative write to the AF-native or Valkyrie-native output file
  # service depending on whether the target FileSet has actually been
  # migrated to Postgres. This is a temporary module until FileSet migration is done.
  #
  # This exists because Hydra::Derivatives.output_file_service is a single
  # global setting, but a legacy ::FileSet and a Postgres-native Hyrax::FileSet
  # need different derivative persistence strategies: ::FileSet derivatives are
  # unmanaged files on local disk (Hyrax::PersistDerivatives), while
  # Hyrax::FileSet derivatives are tracked as Hyrax::FileMetadata records
  # attached to the FileSet resource (Hyrax::ValkyriePersistDerivatives).
  #
  # todovalk: once all ::FileSets have been migrated to Hyrax::FileSet, this
  # service is no longer needed -- set Hydra::Derivatives.output_file_service
  # back to plain Hyrax::ValkyriePersistDerivatives and remove this class.
  class DerivativeOutputFileService < Hydra::Derivatives::PersistOutputFileService
    def self.call(stream, directives)
      target_service_for(directives).call(stream, directives)
    end

    # @param [Hash] directives
    # @return [Class] Hyrax::ValkyriePersistDerivatives or Hyrax::PersistDerivatives
    def self.target_service_for(directives)
      migrated?(file_set_id_for(directives)) ? Hyrax::ValkyriePersistDerivatives : Hyrax::PersistDerivatives
    end

    # Mirrors the URL-parsing convention in Hyrax::ValkyriePersistDerivatives.fileset_for_directives.
    # Kept separate (rather than calling that method) so routing doesn't require
    # a full wings-capable resource resolution just to decide which service to use.
    #
    # @param [Hash] directives
    # @return [String] the FileSet id encoded in the derivative's destination path
    def self.file_set_id_for(directives)
      path = URI(directives.fetch(:url)).path
      return path unless path.include?('/')

      path.sub(Hyrax.config.derivatives_path.to_s, '').delete('/').match(/^(.*)-\w*(\.\w+)*$/) { |m| m[1] }
    end

    # @param [String] id
    # @return [Boolean] true if a genuine Postgres row exists for this id (i.e. the
    #   FileSet has been migrated), without falling through to a wings resolution
    def self.migrated?(id)
      Hyrax.query_service.postgres_service.find_by(id: id)
      true
    rescue Valkyrie::Persistence::ObjectNotFoundError
      false
    end
  end
end
