# Generated via
#  `rails generate hyrax:work ProcessingEvent`
module Hyrax
  # Generated controller for ProcessingEvent
  class ProcessingEventsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Morphosource::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Hyrax::ChildWorkRedirect
    include Morphosource::LinkedTeams::LinkedTeamsManagement

    self.curation_concern_type = ::ProcessingEvent

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ProcessingEventPresenter

    before_action :record_original_parents, only: :update

    def update
      if actor.update(actor_environment)
        update_media_team_access
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

    # old_specimens, new_specimens, old_parent_ancestors, new_parent_ancestors methods used by update_media_team_access
    def old_specimens
      select_specimens(old_parent_ancestors)
    end

    def new_specimens
      select_specimens(new_parent_ancestors)
    end

    def old_parent_ancestors
      ancestors(@original_parents)
    end

    def new_parent_ancestors
      @curation_concern.ancestors
    end
  end
end
