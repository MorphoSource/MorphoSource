module MorphosourceHelper

  def files_required?(work)
    if Hyrax.config.work_requires_files?
      true
    else
      work.class.work_requires_files?
    end
  end

  def find_works_autocomplete_url(curation_concern, relation)
    type_params = valid_lineage_types(curation_concern, relation).map { |type| "type[]=#{type}" }
    Rails.application.routes.url_helpers.qa_path + '/search/find_works?' + type_params.join('&')
  end

  def ms_work_form_tabs(work)
    if files_required?(work)
      %w[metadata files relationships]
    else
      %w[metadata relationships]
    end
  end

  # returns an Array of the class names of the valid relation (child/parent) types for the provided curation concern
  def valid_lineage_types(curation_concern, relation)
    curation_concern.send("valid_#{relation}_concerns").map(&:to_s)
  end

  # returns a string containing the class names of the valid relation (child/parent) types for the provided curation
  # concern with a comma and space between each class name
  def valid_work_types_list(curation_concern, relation)
    valid_lineage_types(curation_concern, relation).join(', ')
  end

end
