# frozen_string_literal: true
require 'builder'

# Provide MorphoSource metadata terms export based on the document's semantic values
module Blacklight::Document::Morphosource
  extend ActiveSupport::Concern
  include Blacklight::Document::MorphosourceFieldSemantics
  include Morphosource::FacetHelper

  def self.extended(document)
    # Register our exportable formats
    Blacklight::Document::Morphosource.register_export_formats( document )
  end

  def self.register_export_formats(document)
    document.will_export_as(:json, "application/json")
  end

  def dublin_core_field_names
    [:contributor, :coverage, :creator, :date, :description, :format, :identifier, :language, :publisher, :relation, :rights, :source, :subject, :title, :type]
  end

  # dublin core elements are mapped against the #dublin_core_field_names whitelist.
  def export_as_json
    to_semantic_values.to_json
  end

  def to_semantic_values
    @semantic_value_hash ||= self.field_semantics.each_with_object(Hash.new([])) do |(key, field_names), hash|
      ##
      # Handles single string field_name or an array of field_names
      value = Array.wrap(field_names).map { |field_name| self[field_name] }.flatten.compact
      # Make single and multi-values all arrays, so clients
      # don't have to know.
      if field_has_helper?(key)
        hash[key] = helper_value(key, value)
      else
        hash[key] = value
      end
    end

    @semantic_value_hash ||= {}
  end

  def field_has_helper?(key)
    helper_fields = [:data_manager, :data_depositor]
    helper_fields.include? (key)
  end

  def helper_value(key, value)
    case key
    when :data_manager
      [user_name_by_id(value.first)]
    when :data_depositor
      [user_name_by_id(value.first)]
    end
  end
end
