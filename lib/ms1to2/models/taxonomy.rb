module Ms1to2
  module Models
    class Taxonomy < BaseObject
      def mappings
        { # MS1 -> MS2
          :ht_kingdom => :taxonomy_kingdom,
          :ht_phylum => :taxonomy_phylum,
          :ht_class => :taxonomy_class,
          :ht_subclass => :taxonomy_subclass,
          :ht_superorder => :taxonomy_superorder,
          :ht_order => :taxonomy_order,
          :ht_suborder => :taxonomy_suborder,
          :ht_superfamily => :taxonomy_superfamily,
          :ht_family => :taxonomy_family,
          :ht_subfamily => :taxonomy_subfamily,
          :genus => :taxonomy_genus,
          :species => :taxonomy_species,
          :subspecies => :taxonomy_subspecies
        }
      end

      def expected_special_fields
        [:depositor]
      end
    end
  end
end 