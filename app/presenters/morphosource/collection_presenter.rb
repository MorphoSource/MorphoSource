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
  end
end
