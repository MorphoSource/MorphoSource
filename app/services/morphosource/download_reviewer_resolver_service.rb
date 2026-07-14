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

      # Resolves download_reviewer values to the ms_ids of the users who
      # should approve download requests. Bare user ms_ids are kept when they
      # name an existing user; prefixed org values expand to the org's
      # reviewers (or its managers when it has none configured).
      def resolve(values)
        user_ids, org_ids = partition_values(values)
        user_ms_ids = User.where(ms_id: user_ids).map(&:ms_id)
        org_ms_ids  = OrganizationCollection.where(id: org_ids)
                                            .flat_map { |org| resolve_organization(org) }
        (user_ms_ids + org_ms_ids).uniq
      end

      # Resolves the reviewer user ms_ids for a media work or media solr doc:
      # its download_reviewer values when they resolve to at least one user,
      # otherwise its owner (an org owner expands to the org's reviewers).
      def resolve_for_media(media)
        if media.download_reviewer.present?
          resolved = resolve(media.download_reviewer)
          return resolved if resolved.present?
        end

        resolve_owner(media.user_with_ownership)
      end

      # Resolves an organization's reviewers to user ms_ids: its
      # download_reviewer values when set, otherwise its managers.
      # visited guards against cycles (e.g. Org A → Org B → Org A).
      def resolve_organization(org, visited = Set.new)
        return [] if visited.include?(org.id)
        visited << org.id

        return org.managers.map(&:ms_id) if org.download_reviewer.blank?

        user_ids, org_ids = partition_values(org.download_reviewer)
        user_ms_ids = User.where(ms_id: user_ids).map(&:ms_id)
        nested_ms_ids = OrganizationCollection.where(id: org_ids)
                                              .flat_map { |nested| resolve_organization(nested, visited) }
        (user_ms_ids + nested_ms_ids).uniq
      end

      # Resolves an ownership value (a bare user ms_id or org id) to user ms_ids
      def resolve_owner(ownership)
        if (org = OrganizationCollection.find_by(id: Array(ownership)))
          resolve_organization(org)
        else
          Array(ownership)
        end
      end
    end
  end
end
