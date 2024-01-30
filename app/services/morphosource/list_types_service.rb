# app/services/morphosource/list_types_service.rb
module Morphosource
  # Provide select options for the list types field
  class ListTypesService < QaSelectService
    def initialize(_authority_name = nil)
      super('list_types')
    end

    def help_text_list(value=nil)
      options = []
      authority.all.map do |element|
        opt = [element[:id], authority.find(element[:id]).fetch(:help_text)]
        options << opt
      end
      return options
    end

  end
end
