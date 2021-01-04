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
    self.curation_concern_type = ::ImagingEvent

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ImagingEventPresenter

    before_action :record_original_parents, only: :update

    def update
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

    private

    def old_specimens
      select_specimens(@original_parents)
    end

    def new_specimens
      select_specimens(@curation_concern.member_of)
    end
  end
end
