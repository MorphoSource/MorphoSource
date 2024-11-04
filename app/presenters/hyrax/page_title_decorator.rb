# frozen_string_literal: true

module Hyrax
  ##
  # Decorates Work-like objects with a `#title` and `#page_title` for display.
  class PageTitleDecorator < Draper::Decorator
    ##
    # overlays the `#title` of the object, making an effort to guarantee
    # a reasonable title is found. if one isn't found, it uses an i18n
    # key to produce a generic 'No Title' string.
    #
    # @return [String] a displayable title for this object
    def title
      title = Array(object.try(:title)).join(' | ')
      return title if title.present?
      label = Array(object.try(:label)).join(' | ')
      return label if label.present?

      h.t('hyrax.works.missing_title')
    end

    ##
    # @return [String] a title for pages about this object
    def page_title
      if object.persisted?
        result = "#{object.human_readable_type} [#{object.to_param}] // #{h.application_name}"
        title + ' // ' + result
      else
        "New #{object.human_readable_type} // #{h.application_name}"
      end
    end
  end
end