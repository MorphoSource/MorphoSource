# Generated via
#  `rails generate hyrax:work Taxonomy`
# @deprecated Taxonomy creation/update goes through the taxonomy_change_set transaction
#   (see Hyrax::TaxonomiesController), not the actor stack. This class has no live caller;
#   it exists only so that Hyrax's naming-convention-based actor lookup for :taxonomy
#   fails loudly instead of silently doing the wrong thing if anything ever reaches it.
module Hyrax
  module Actors
    class TaxonomyActor < Hyrax::Actors::BaseActor
      # @defunct
      def create(env)
        raise NotImplementedError, "Taxonomies are deprecated, use TaxonomyResource and Transactions instead."
      end
      alias update create
    end
  end
end
