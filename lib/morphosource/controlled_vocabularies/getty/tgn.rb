module Morphosource
  module ControlledVocabularies
    module Getty
      class Tgn < ActiveTriples::Resource
        include  Morphosource::ControlledVocabularies::GettyAuthorities

        class_attribute :label, :full_label

        def cache_key_prefix
          'morphosource_getty_tgn_label-v1-'
        end

        def service_name
          'tgn'
        end

    end
  end
end
end
