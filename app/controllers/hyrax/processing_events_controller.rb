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
      # Handle possible attachment upload
      if params[:pe_description] && Morphosource.attachment_formats.include?(File.extname(params[:pe_description].original_filename))
        Morphosource::AttachmentService.create(curation_concern.id, 'pe_description', params[:pe_description])
        params.delete(:pe_description)
      elsif params[:pe_description_attachment_delete] == 'delete'
        Morphosource::AttachmentService.delete(curation_concern.id, 'pe_description')
        params.delete(:pe_description_attachment_delete)
      end

      env = actor_environment
      emancipate_if_necessary(env)
      if actor.update(env)
        update_media_team_access
        update_media_physical_object_ids
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

    def emancipate_if_necessary(env)
      attrs = env.attributes
      new_parent_ids = []
      if attrs['work_parents_attributes'].present?
        attrs['work_parents_attributes'].each do |key, wp|
          new_parent_ids << wp['id'] if wp['_destroy'] == "false"
        end
      end

      if new_parent_ids.present?
        id = attrs['id'].presence || env.curation_concern.id.presence || ''
        old_parents = ProcessingEvent.find(id).member_of

        old_parents.each do |op|
          if !new_parent_ids.include?(op.id)
            attrs['work_parents_attributes'][attrs['work_parents_attributes'].length.to_s] = {
              'id' => op.id, '_destroy' => "true"
            }
          end
        end

      attrs
      end
    end

    def update_media_physical_object_ids
      @curation_concern.descendants.select { |d| d.class == Media }.each { |m| m.update_physical_object_id }
    end

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
