# frozen_string_literal: true
module Morphosource
  ##
  # Brings an AR-style +member_of+ accessor to Valkyrie resources, returning
  # the parent works (both Valkyrie and ActiveFedora) that list this resource
  # in their +:member_ids+ / +valkyrie_member_ids+.
  #
  # This concern can be included on any Valkyrie resource that has an +id+,
  # including leaf nodes like +Hyrax::FileSet+ that have no children of their own.
  module ArResourceParentship
    extend ActiveSupport::Concern

    def member_of(include_af_works: true)
      parents = Hyrax.query_service.postgres_service.find_inverse_references_by(
        id: id.to_s, property: :member_ids
      ).to_a

      if include_af_works
        parents.concat(ActiveFedora::Base.where(valkyrie_member_ids_ssim: id.to_s).to_a)
      end

      parents.uniq { |p| p.id.to_s }
    end

    def parent(include_af_works: true)
      member_of(include_af_works: include_af_works)&.first
    end
  end
end
