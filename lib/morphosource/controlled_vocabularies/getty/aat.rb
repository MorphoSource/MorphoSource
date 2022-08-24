module Morphosource
  module ControlledVocabularies
    module Getty
      class Aat < ActiveTriples::Resource
        include Morphosource::ControlledVocabularies::GettyAuthorities

        class_attribute :label

        def cache_key_prefix
          'morphosource_getty_aat_label-v1-'
        end

        def service_name
          'aat'
        end
    end
  end
end
end
