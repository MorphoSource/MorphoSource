# frozen_string_literal: true
module Morphosource
  module Transactions
    module Taxonomy
      module Steps
        ##
        # A step that sets the title for a taxonomy ChangeSet based on other taxonomy fields.
        class SetTitle
          include Dry::Monads[:result]

          ##
          # @param [Hyrax::ChangeSet] obj
          #
          # @return [Dry::Monads::Result]
          def call(obj)
            return Failure[:not_taxonomy_change_set, obj] unless obj.is_a?(TaxonomyResourceForm)

            obj.title = [generated_title(obj)]

            Success(obj)
          end

          private

            def generated_title(obj)
              if obj.taxonomy_genus.present?
                species_term = obj.taxonomy_species.present? ? " #{Array(obj.taxonomy_species).first}" : " sp."
                subspecies_term = obj.taxonomy_species.present? && obj.taxonomy_subspecies.present? ? " #{Array(obj.taxonomy_subspecies).first}" : ""
                Array(obj.taxonomy_genus).first + species_term + subspecies_term
              else
                lowest_rank_term = 'Taxonomy'
                higher_ranks.each do |hr|
                  rank_value = obj.public_send(hr)
                  lowest_rank_term = Array(rank_value).first if rank_value.present?
                end
                "#{lowest_rank_term} indet."
              end
            end

            def higher_ranks
              ["taxonomy_domain","taxonomy_kingdom","taxonomy_phylum","taxonomy_superclass","taxonomy_class","taxonomy_subclass","taxonomy_superorder","taxonomy_order","taxonomy_suborder","taxonomy_superfamily","taxonomy_family","taxonomy_subfamily","taxonomy_tribe"]
            end
        end
      end
    end
  end
end
