module Morphosource
  # Overrides methods from Hyrax::SearchState to enable support for facet f.field format url params
  class SearchState < Hyrax::SearchState
    # copies the current params (or whatever is passed in as the 3rd arg)
    # removes the field value from params[:f]
    # removes the field if there are no more values in params[:f][field]
    # removes additional params (page, id, etc..)
    def remove_facet_params(field, item)
      # remove f[key][] format facets
      p = super

      # remove f.key format facets

      if item.respond_to? :field
        field = item.field
      end

      facet_config = facet_configuration_for_field(field)
      url_field = facet_config.key

      value = facet_value_for_facet_item(item)

      # need to dup the facet values too,
      # if the values aren't dup'd, then the values
      # from the session will get remove in the show view...
      p["f.#{url_field}"] = (p["f.#{url_field}"]).dup

      # existing facet value(s) might be an array or a single string, but it could also be a hash
      # Facebook (and maybe some other PHP tools) tranform parameters f[key][] into f[key][0],
      # which Rails interprets as a Hash.
      existing_values = p["f.#{url_field}"]

      if existing_values.is_a? Hash
        existing_values = existing_values.values
      end

      if existing_values.is_a? Array
        p["f.#{url_field}"] = existing_values - [value]
        p.delete("f.#{url_field}") if p["f.#{url_field}"].empty?
      else
        p.delete("f.#{url_field}")
      end

      p
    end

    private

    def add_facet_param(p, field, item)
      if item.respond_to? :field
        field = item.field
      end

      facet_config = facet_configuration_for_field(field)
      url_field = facet_config.key

      value = facet_value_for_facet_item(item)

      # account for previously existing values
      # if value is already present and we can select multiple values, then add all values as array
      # if can only select one value for facet or no previous values present, this value becomes only value
      p["f.#{url_field}"] = p["f.#{url_field}"].dup
      if p["f.#{url_field}"].present? && !facet_config.single
        p["f.#{url_field}"] = Array(p["f.#{url_field}"]).push(value)
      else
        p["f.#{url_field}"] = value
      end
    end
  end
end
