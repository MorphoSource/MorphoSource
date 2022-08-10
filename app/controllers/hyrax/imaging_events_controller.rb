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
      # Handle possible attachment upload
      if params[:ie_description] && Morphosource.attachment_formats.include?(File.extname(params[:ie_description].original_filename))
        Morphosource::AttachmentService.delete(curation_concern.id, 'ie_description')
        Morphosource::AttachmentService.create(curation_concern.id, 'ie_description', params[:ie_description], Morphosource.attachment_formats)
        params.delete(:ie_description)
      elsif params[:ie_description_attachment_delete] == 'delete'
        Morphosource::AttachmentService.delete(curation_concern.id, 'ie_description')
        params.delete(:ie_description_attachment_delete)
      end

      if params[:ie_reference] && Morphosource.reference_attachment_formats.include?(File.extname(params[:ie_reference].original_filename))
        Morphosource::AttachmentService.delete(curation_concern.id, 'ie_reference')
        Morphosource::AttachmentService.create(curation_concern.id, 'ie_reference', params[:ie_reference], Morphosource.reference_attachment_formats)
        params.delete(:ie_reference)
      elsif params[:ie_reference_attachment_delete] == 'delete'
        Morphosource::AttachmentService.delete(curation_concern.id, 'ie_reference')
        params.delete(:ie_reference_attachment_delete)
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
