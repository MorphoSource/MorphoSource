module Morphosource
  class QaSelectService < Hyrax::QaSelectService

    def select_all_options(value=nil)
      options = []
      authority.all.map do |element|
        opt = [element[:label], element[:id]]
        if value.present? 
          # as long as the value matches (case insensitive), the option will be selected 
          if value.kind_of?(ActiveTriples::Relation)
            if value.first.downcase == element[:id].downcase              
              opt = [element[:label], value.first]
            end
          elsif value.kind_of?(String)
            if value.downcase == element[:id].downcase              
              opt = [element[:label], value]
            end
          else
byebug
            Rails.logger.debug "in select_all_options: unexpected class #{value.class} of value #{value}"
          end
        end
        options << opt
      end
      return options
    end

    def active?(id)
      if authority.find(id).key?('active')
        authority.find(id).fetch('active')
      else
        return false
      end
    end

  end
end
