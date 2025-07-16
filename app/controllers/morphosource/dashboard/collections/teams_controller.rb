module Morphosource
  module Dashboard
    module Collections
      class TeamsController < Morphosource::Dashboard::CollectionsController

        skip_load_and_authorize_resource only: [:edit, :update, :new, :projects, :organization, :members], instance_name: :collection

        before_action :redirect_to_collection_type, only: []

        self.presenter_class = Morphosource::Collections::TeamPresenter

        def edit
          organization_presenter
          super
        end

        def projects
          @tab = :projects
          @projects = member_subcollections
          presenter
          render 'edit'
        end

        def organization
          @tab = :organization
          @organization = @collection.organization
          organization_presenter
          presenter
          form
          render 'edit'
        end

        private

          def collection_type
            Hyrax::CollectionType.find_by(title: "Team")
          end
          alias :default_collection_type :collection_type

          def organization_presenter
            @organization ||= @collection.organization
            return nil unless @organization

            Hyrax::OrganizationPresenter.new(@organization, current_ability, nil)
          end

      end
    end
  end
end
