module Morphosource
  module Dashboard
    module Collections
      class TeamsController < Morphosource::Dashboard::CollectionsController

        skip_load_and_authorize_resource only: [:edit, :update, :new], instance_name: :collection

        before_action :redirect_to_collection_type, only: []
        before_action :build_breadcrumbs, only: []
        before_action :load_collection


        self.presenter_class = Morphosource::Collections::TeamPresenter

        def edit
          @projects = member_subcollections
          organization_presenter
          super
        end

        private

          def member_subcollections
            docs = Morphosource::SolrService.new.get_docs("has_model_ssim:Collection AND member_of_collection_ids_ssim:#{@collection.id}")
            docs.each do |doc|
              media_count = Morphosource::SolrService.new.get_docs("member_of_collection_ids_ssim:#{doc['id']}").count
              doc.merge!({"media_count" => media_count})
            end
          end

          def default_collection_type
            Hyrax::CollectionType.find_by(title: "Team")
          end

          def organization_presenter
            @organization ||= @collection.organization
            return nil unless @organization

            @organization_presenter = Hyrax::OrganizationPresenter.new(@organization, current_ability, nil)
          end

      end
    end
  end
end
