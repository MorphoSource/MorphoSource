
module Hyrax
  module Renderers
    class ShowcaseDateAttributeRenderer < ShowcaseDefaultAttributeRenderer

      private

        def attribute_value_to_html(value)
          begin
            # TODO: currently Date.parse is expecting formats e.g. "26/04/2019", "2019-04-26"
            # "04/26/2019" will throw invalid date exception
            # Depending on the date picker on the form, we might need to use DateTime.strptime instead
            Date.parse(value).to_formatted_s(:long)
          rescue StandardError => e
            if e.message == 'invalid date'
              value # just return the string as it is
            else
              # if landed here. check e.message for the exception message
              '(Error)'
            end
          end
        end

    end
  end
end