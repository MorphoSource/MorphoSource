# Generated via
#  `rails generate hyrax:work ImagingEvent`
module Hyrax
  # Generated controller for ImagingEvent
  class ImagingEventsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Morphosource::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Hyrax::ChildWorkRedirect
    include Morphosource::LinkedTeams::LinkedTeamsManagement

    skip_authorize_resource only: :media_owner_update
    
    self.curation_concern_type = ::ImagingEvent

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ImagingEventPresenter

    before_action :record_original_objects, only: :update

    def update
      if po_changed
        record_original_objects
      end

      # Handle possible new attachment upload, delete or replace attachment
      if params[:ie_description_delete] == 'delete'
        curation_concern.description_attachment = nil
      end
      if params[:ie_description].present?
        curation_concern.description_attachment = params[:ie_description]
      end      

      if params[:ie_reference_delete] == 'delete'
        curation_concern.reference_attachment = nil
      end
      if params[:ie_reference].present?
        curation_concern.reference_attachment = params[:ie_reference]
      end      

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

    def media_owner_update
      if (
        params["media_id"].present? && 
        curation_concern.media.map(&:id).include?(params["media_id"]) && 
        current_user.can?(:edit, params["media_id"])
      )
        update
      else
        # unauthorized, return
        respond_to do |wants|
          wants.html { redirect_to main_app.root_url, alert: "Unauthorized." }
          wants.json { render_json_response(response_type: :forbidden) }
        end
      end
    end

    def po_changed
      @po_changed ||= begin
        if params[:imaging_event] && params[:imaging_event][:physical_object_id]
          (curation_concern.physical_object_id != params[:imaging_event][:physical_object_id])
        else
          false
        end
      end
    end

    private

    def old_physical_objects
      select_physical_objects(@original_objects)
    end

    def new_physical_objects
      ActiveFedora::Base.find(Array(@curation_concern.physical_object_id))
    end
  end
end
