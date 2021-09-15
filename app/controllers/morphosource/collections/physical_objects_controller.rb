module Morphosource
  module Collections
    class PhysicalObjectsController < Morphosource::CollectionsController
      include Morphosource::Collections::LinkedTeamsControllerBehavior

      before_action :load_organization, only: [:show]

      def filtered_facets
        ["media_member_of_project_ids_ssim", "media_member_of_team_ids_ssim"]
      end

      def search_builder
        search_builder_class.new(self)
      end

      def presenter_class
        @collection ||= ::Collection.find(params[:id])
        if @collection.project?
          Morphosource::Collections::ProjectPresenter
        elsif @collection.team?
          Morphosource::Collections::TeamPresenter
        end
      end
    end
  end
end
