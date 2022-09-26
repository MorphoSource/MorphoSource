module Morphosource
  class QaSelectService < Hyrax::QaSelectService

    def option_values
      select_all_options.map{ |o| o[1] }
    end

    def select_all_options(value=nil)
      options = []
      authority.all.map do |element|
        opt = [element[:label], element[:id]]
        if value.present? 
          # as long as the value matches (case insensitive), the option will be selected 
          if value.kind_of?(ActiveTriples::Relation) || value.kind_of?(Array)
            if value.first.downcase == element[:id].downcase              
              opt = [element[:label], value.first]
            end
          elsif value.kind_of?(String)
            if value.downcase == element[:id].downcase              
              opt = [element[:label], value]
            end
          else
            Rails.logger.debug "in select_all_options: unexpected class #{value.class} of value #{value}"
          end
        end
        options << opt
      end
      return options
    end

    def controlled_value(value)
      return_value = value
      authority.all.map do |element|
        # as long as the value matches (case insensitive), return the value in proper case
        if value.kind_of?(ActiveTriples::Relation) || value.kind_of?(Array)
          if value.first.downcase == element[:id].downcase              
            return_value = element[:id]
          end
        elsif value.kind_of?(String)
          if value.downcase == element[:id].downcase              
            return_value = element[:id]
          end
        else
          Rails.logger.debug "in controlled_value: unexpected class #{value.class} of value #{value}"
        end
      end
      return return_value
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
