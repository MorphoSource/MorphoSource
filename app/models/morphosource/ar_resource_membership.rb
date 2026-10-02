# frozen_string_literal: true
module Morphosource
  ##
  # Brings an AR-style +members+ accessor to Valkyrie resources that define
  # +:member_ids+, returning child resources (both Valkyrie and ActiveFedora).
  #
  # This concern requires the including class to implement +member_ids+. For
  # parent-finding only (e.g. on leaf nodes like +Hyrax::FileSet+), include
  # +Morphosource::ArResourceParentship+ instead.
  #
  # @note +:member_ids+ holds ids of child works and file sets.
  # @note This will currently double-query AF works, but could be optimised by
  #   checking the model registry in Wings query_service before querying.
  module ArResourceMembership
    extend ActiveSupport::Concern

    included do
      include Morphosource::ArResourceParentship
    end

    def members(include_af_works: true)
      children = member_ids.map do |id|
        Hyrax.query_service.postgres_service.find_by(id: id)
      rescue Valkyrie::Persistence::ObjectNotFoundError
        next
      end.compact

      if include_af_works
        children.concat(
          (member_ids.map(&:to_s) - children.map(&:id).map(&:to_s)).uniq.map do |id|
            ActiveFedora::Base.find(id)
          rescue ::ActiveFedora::ObjectNotFoundError, Ldp::Gone
            next
          end.compact
        )
      end

      return children
    end
  end
end