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

    def media_list?
      self.class == Morphosource::Collections::MediaListPresenter
    end

    def sequential_section_list?
      self.class == Morphosource::Collections::MediaLists::SequentialSectionListPresenter
    end

    def organization?
      self.class == Morphosource::Collections::OrganizationPresenter
    end
    alias organization_collection? organization?

    def list?
      media_list? || sequential_section_list?
    end

    def can_remove_media_from?
      (team? || project? || list?)
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

    def collection_type_badge_short
      content_tag(:span, collection_type.title&.first || "C", class: "label label-info short-collection-badge", style: "background-color: " + collection_type.badge_color + ";", title: collection_type.title || "Unknown Collection Type")
    end

    def collection_type_title
      collection_type.title
    end

    def collection_type_machine_id
      collection_type.machine_id
    end

    def membership(current_user)
      if collection.managers.include?(current_user)
        'Manager'
      elsif collection.editors.include?(current_user)
        'Editor'
      elsif collection.viewers.include?(current_user)
        'Viewer'
      elsif collection.downloaders.include?(current_user)
        'Downloader'
      elsif collection.depositors.include?(current_user)
        'Depositor'
      else
        ''
      end
    end

    def model
      solr_document.to_model
    end

    def total_viewable_media
      ActiveFedora::Base.where("member_of_collection_ids_ssim:#{id} AND has_model_ssim:Media").accessible_by(current_ability).count
    end
  end
end
