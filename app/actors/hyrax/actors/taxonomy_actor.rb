# Generated via
#  `rails generate hyrax:work Taxonomy`
module Hyrax
  module Actors
    class TaxonomyActor < Hyrax::Actors::BaseActor

      def create(env)
        env.attributes['title'] = [ generated_title(env) ]
        env.attributes['source'] = [ generated_source(env) ]
        env.attributes['trusted'] = [ generated_trusted(env) ]
        super
      end

      def update(env)
        env.attributes['title'] = [ generated_title(env) ]
        env.attributes['source'] = [ generated_source(env) ]
        env.attributes['trusted'] = [ generated_trusted(env) ]
        super
      end

      private

        def generated_title(env)
          get_ranks(env.attributes).join(' > ')
        end

        def generated_source(env)
          if env.attributes["source"] && !env.attributes["source"].first.blank?
            env.attributes["source"].first
          elsif !env.curation_concern.source.blank?
            env.curation_concern.source.first
          else
            "User-Provided"
          end
        end

        def generated_trusted(env)
          if env.attributes["trusted"] && !env.attributes["trusted"].first.blank?
            env.attributes["trusted"].first
          elsif !env.curation_concern.trusted.blank?
            env.curation_concern.trusted.first
          else
            "No"
          end
        end

        def get_ranks(attrs)
          all_ranks = ["taxonomy_domain","taxonomy_kingdom","taxonomy_phylum","taxonomy_superclass","taxonomy_class","taxonomy_subclass","taxonomy_superorder","taxonomy_order","taxonomy_suborder","taxonomy_superfamily","taxonomy_family","taxonomy_subfamily","taxonomy_tribe","taxonomy_genus","taxonomy_subgenus","taxonomy_species","taxonomy_subspecies"]
          all_ranks.map!{|rank| attrs[rank].presence ? attrs[rank].first : ""}
          all_ranks.keep_if{|rank| rank.present?}
        end

    end
  end
end
