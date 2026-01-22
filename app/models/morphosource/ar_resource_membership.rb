# frozen_string_literal: true
module Morphosource
  ##
  #
  # an optional module to bring active record like membership accessors to Valkyrie resources. This
  # is especially useful for resources that may have a mix of AF work and Valkyrie resource parents
  # and children.
  #
  # Repeating information from Hyrax::Work about work membership in Valkyrie
  #
  # ### Work and Work
  #
  # * Defined: The relationship is defined in the parent work's `:member_ids` attribute.
  # * Tested: The relationship is tested in shared spec `'a Hyrax::Work'` by testing
  #   `it_behaves_like 'has_members'`.  Shared specs are defined in /lib /hyrax/specs/shared_specs/hydra_works.rb.
  # * Work to child Work: (0..m)  A work can have many child works.
  #
  # @example Add a child work to a work:
  #       Hyrax::Transactions::Container['work_resource.add_to_parent']
  #         .call(child_work, parent_id: parent_work.id, user: current_user)
  # @example Get child works:
  #       works = Hyrax.custom_queries.find_child_works(resource: parent_work)
  #
  # * Work to parent Work: (0..1)  A work can be in at most one parent work.
  #
  # @example Get parent work:
  #       parent_work = Hyrax.custom_queries.find_parent_work(resource: child_work)
  #
  # @note `:member_ids` holds ids of child works and file sets.
  #
  # Compared to the above, this module gives more active record style ways of doing some of the same things
  module ArResourceMembership
    extend ActiveSupport::Concern

    # This will currently double-query AF works, but could modify Wings query_service.rb to prevent that by checking model registry before query
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

    def member_of(include_af_works: true)
      parents = Hyrax.query_service.postgres_service.find_inverse_references_by(
        id: id.to_s, property: :member_ids
      ).to_a

      if include_af_works
        parents.concat(ActiveFedora::Base.where(valkyrie_member_ids_ssim: id.to_s).to_a)
      end

      return parents
    end
  end
end