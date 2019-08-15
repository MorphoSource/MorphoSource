





# might not need this form builder.  remove later









module Hyrax
  class ShowcaseFormBuilder < Hyrax::FormBuilder
    def input(attribute_name, options={})
     # super(attribute, options.reverse_merge(placeholder: "Your name please"))
      options = @defaults.deep_dup.deep_merge(options) if @defaults

      input   = find_input(attribute_name, options)
byebug
      input.html_safe

    end
 
  end
end