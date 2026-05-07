Rails.application.config.to_prepare do
  ControlledVocabularyInput.class_eval do
    private

    def build_options_for_existing_row(_attribute_name, _index, value, options)
      options[:value] = value.rdf_label.first || "Unable to fetch label for #{value.rdf_subject}"
      options[:data][:label] = value.full_label || value.rdf_label.first
      options[:readonly] = true
    end
  end
end
