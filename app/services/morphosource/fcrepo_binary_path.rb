# frozen_string_literal: true
module Morphosource
  # Given an FCRepo FileSet SHA1 digest, calculates the on-disk binary file path.
  class FcrepoBinaryPath
    # @param digest [String, #to_s] e.g. "urn:sha1:<40 hex chars>", or the bare hash
    # @return [Pathname]
    # @raise [ArgumentError] if digest isn't a well-formed SHA-1 hex digest
    def self.for(digest)
      sha1 = digest.to_s.sub(/\Aurn:sha1:/, '')
      raise ArgumentError, "Not a SHA-1 hex digest: #{digest.inspect}" unless sha1.match?(/\A[0-9a-fA-F]{40}\z/)

      subdirs = sha1[0, 6].chars.each_slice(2).map(&:join)
      Pathname.new(Hyrax.config.fcrepo_binary_directory_path.to_s).join(*subdirs, sha1)
    end
  end
end
