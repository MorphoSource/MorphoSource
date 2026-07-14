# frozen_string_literal: true

module Morphosource
  # Resolves download_reviewer identifiers to reviewer users.
  #
  # download_reviewer fields hold two kinds of values:
  #   - bare user ms_ids (e.g. "000123456")
  #   - organization collection ids prefixed with ORG_PREFIX (e.g. "org_collection:ab12cd34e"),
  #     so org values can be told apart from user values without a database lookup
  class DownloadReviewerResolverService
    ORG_PREFIX = 'org_collection:'

    class << self
      def org_value?(value)
        value.to_s.start_with?(ORG_PREFIX)
      end

      # Formats an organization collection id for storage in a download_reviewer field
      def org_value(org_id)
        "#{ORG_PREFIX}#{org_id}"
      end

      # Extracts the organization collection id from a prefixed download_reviewer value
      def org_id(value)
        value.to_s.delete_prefix(ORG_PREFIX)
      end

      # Splits raw download_reviewer values into [user_ms_ids, org_ids],
      # stripping the prefix from the org ids
      def partition_values(values)
        org_values, user_ms_ids = Array(values).partition { |v| org_value?(v) }
        [user_ms_ids, org_values.map { |v| org_id(v) }]
      end
    end
  end
end
