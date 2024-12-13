# frozen_string_literal: true
class Hyrax::HomepageController < ApplicationController
  # Adds Hydra behaviors into the application controller
  include Blacklight::SearchContext
  include Blacklight::AccessControls::Catalog

  class_attribute :presenter_class
  self.presenter_class = Hyrax::HomepagePresenter
  layout 'homepage'
  helper Hyrax::ContentBlockHelper

  def index
    @presenter = presenter_class.new(current_ability, collections)
    get_featured_projects
  end

  private

  # Return 5 collections
  def collections(rows: 5)
    Hyrax::CollectionsService.new(self).search_results do |builder|
      builder.rows(rows)
    end
  rescue Blacklight::Exceptions::ECONNREFUSED, Blacklight::Exceptions::InvalidRequest
    []
  end

  def get_featured_projects
    @featured_projects ||= begin
      project_ids = Rails.application.config.featured_project_ids
      if project_ids.blank?
        collections(rows: 6)
      else
        project_ids.each_with_object([]) do |id, projects|
          projects << ::SolrDocument.find(id)
        end
      end
      rescue Blacklight::Exceptions::RecordNotFound
      collections(rows: 6)
    end
  end

  def recent
    # grab any recent documents
    (_, @recent_documents) = search_service.search_results do |builder|
      builder.rows(4)
      builder.merge(sort: sort_field)
    end
  rescue Blacklight::Exceptions::ECONNREFUSED, Blacklight::Exceptions::InvalidRequest
    @recent_documents = []
  end

  def search_service
    Hyrax::SearchService.new(config: blacklight_config, user_params: { q: '' }, scope: self, search_builder_class: Hyrax::HomepageSearchBuilder)
  end

  def sort_field
    "date_uploaded_dtsi desc"
  end
end
