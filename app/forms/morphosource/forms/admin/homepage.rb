module Morphosource
  module Forms
    module Admin
      class Homepage < Morphosource::Forms::Admin::Appearance

        SETTINGS = %w[featured_collections].freeze

        SORTED_COLLECTIONS = %w[featured_collection_1
                                featured_collection_2
                                featured_collection_3
                                featured_collection_4
                                featured_collection_5
                                featured_collection_6
                                featured_collection_7
                                featured_collection_8
                                featured_collection_9
                                featured_collection_10].freeze

        # Individual collection IDs for the featured collections are not stored in separate fields,
        # but rather as a comma-separated list in the `featured_collections` block.
        def self.define_sorted_collections
          self::SORTED_COLLECTIONS.each do |method_name|
            define_method(method_name) do
              # "featured_collection_1" -> 0
              index = method_name[/\d+$/].to_i - 1
              return nil unless index < featured_collections.size
              featured_collections[index]
            end
          end
        end

        define_sorted_collections

        def featured_collections
          block_for(:featured_collections, "").split(",")
        end
      end
    end
  end
end