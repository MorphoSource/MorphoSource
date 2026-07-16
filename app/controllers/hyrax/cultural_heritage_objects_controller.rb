# Generated via
#  `rails generate hyrax:work CulturalHeritageObject`
module Hyrax
  # Generated controller for CulturalHeritageObject
  class CulturalHeritageObjectsController < ApplicationController
    # Adds Hyrax behaviors to the controller
    include Morphosource::CurationConcernControllerBehavior
    include Hyrax::WorksControllerBehavior
    include Hyrax::ChildWorkRedirect
    include Morphosource::LinkedTeams::LinkedTeamsManagement
    prepend Morphosource::HaltedDestroyResponse
    self.curation_concern_type = ::CulturalHeritageObject
    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::CulturalHeritageObjectPresenter

    before_action :record_original_organizations, only: :update

    skip_authorize_resource only: :showcase

    # override the layout from WorksControllerBehavior
    def decide_layout
      layout = case action_name
               when 'show'
                 '1_column'
               when 'showcase'
                 'morphosource_2_columns'
               # todo: later might need to add different layout for EDIT or other actions here
               when 'edit'
                 'morphosource_2_columns'
               else
                 'dashboard'
               end
      File.join(theme, layout)
    end

    def showcase
      @presenter = show_presenter.new(search_result_document(id: params[:id]), current_ability, request)
      render 'showcase', presenter: @presenter
    end

    # overriding action methods from works_controller_behavior.rb
    def edit
      build_form
      @presenter = show_presenter.new(search_result_document(id: params[:id]), current_ability, request)
      @countries_service = Morphosource::CountriesService.new
      render 'edit', presenter: @presenter
    end

    def new
      curation_concern.depositor = current_user.user_key
      curation_concern.admin_set_id = admin_set_id_for_new
      build_form
      render '/hyrax/base/new'
    end

    def update
      if actor.update(actor_environment)
        update_media_team_access
        update_po_team_access
        after_update_response
      else
        respond_to do |wants|
          wants.html do
            build_form
            render 'edit', status: :unprocessable_entity
          end
          wants.json { render_json_response(response_type: :unprocessable_entity, options: { errors: curation_concern.errors }) }
        end
      end
    end

    private

    def old_orgs
      @original_organizations
    end

    def new_orgs
      ActiveFedora::Base.find(Array(@curation_concern.organization_id))
    end
  end
end
