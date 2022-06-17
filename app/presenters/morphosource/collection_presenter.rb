module Morphosource
  class CollectionPresenter < Hyrax::CollectionPresenter

    attr_reader :collection, :collection_managers, :search_form_url

    attr_writer :collection_type

    def initialize(solr_document, current_ability, request = nil)
      super
      @search_form_url = ''
      @collection ||= Collection.find(id)
      @collection_managers = manager_list(@collection.managers)
    end

    def team?
      self.class == Morphosource::Collections::TeamPresenter
    end

    def project?
      self.class == Morphosource::Collections::ProjectPresenter
    end

    def manager_list(managers)
      ml = []
      managers.each do |m|
        renderer = Hyrax::Renderers::ShowcaseUserLinkAttributeRenderer.new(nil,nil)
        ml << renderer.user_link(m)
      end
      ml.join(', ').html_safe
    end

    def id_badge
      content_tag(:span, "ID: #{id}", class: "label label-info")
    end

    def organization_badge
      content_tag(:span, "Organization", class: "label label-success")
    end

    def team_managed_badge
      content_tag(:span, "Team Managed", class: "label", style: "background-color: #FF861F;")
    end
  end
end
