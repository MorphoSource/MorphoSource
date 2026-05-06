# Generated via
#  `rails generate hyrax:work ProcessingEvent`
module Hyrax
  # Generated controller for ProcessingEvent
  class ProcessingEventsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Morphosource::WorksControllerBehavior
    include Hyrax::ChildWorkRedirect
    include Morphosource::LinkedTeams::LinkedTeamsManagement

    skip_authorize_resource only: :media_owner_update

    self.curation_concern_type = ::ProcessingEvent

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ProcessingEventPresenter

    before_action :record_original_parents, only: :update
    before_action :check_processing_activity, only: :media_owner_update

    def update
      # Handle possible new attachment upload, delete or replace attachment
      if params[:pe_description_delete] == 'delete'
        curation_concern.description_attachment = nil
      end
      if params[:pe_description].present?
        curation_concern.description_attachment = params[:pe_description]
      end      
      env = actor_environment
      emancipate_if_necessary(env)
      if actor.update(env)
        update_media_team_access
        reindex_related_media
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

    def reindex_related_media
      if params["processing_event"] && params["processing_event"]["work_parents_attributes"].present? &&
        (media_id = params["media_id"]).present?
        # parent media changed in the media edit page
        # reindex current media first (which is needed before reindexing the related media)
        # then reindex the related media
        UpdateWorkIndexJob.perform_later(media_id)
        # TODO: Drop the _tesim fallback after all Media documents are reindexed with imaging_event_id_ssim.
        qry = "has_model_ssim:Media AND " \
          "(imaging_event_id_ssim:\"#{@curation_concern.imaging_event.id}\" OR " \
          "imaging_event_id_tesim:\"#{@curation_concern.imaging_event.id}\")"
        related_media_solr = ::Morphosource::SolrService.new().get_docs(qry, args: { fl: 'id' } )
        related_media_ids = related_media_solr.map { |d| d['id'] }.reject { |id| id == media_id }
        related_media_ids.each do |id|
          UpdateWorkIndexJob.perform_later(id)
        end
      end
    end

    # old_physical_objects, new_physical_objects, old_parent_ancestors, new_parent_ancestors methods used by update_media_team_access
    def old_physical_objects
      orig_parents = @original_parents || []
      select_physical_objects((orig_parents + old_parent_ancestors).uniq.select(&:imaging_event?).map(&:objects).flatten)
    end

    def new_physical_objects
      select_physical_objects((new_parents + new_parent_ancestors).uniq.select(&:imaging_event?).map(&:objects).flatten)
    end

    def old_parent_ancestors
      ancestors(@original_parents)
    end

    def new_parent_ancestors
      ancestors(new_parents)
    end

    def new_parents
      @curation_concern.member_of
    end

    def check_processing_activity
      if params["processing_event"]["processing_activity"].present?
        steps = params["processing_event"]["processing_activity"].map { |activity| activity.split(',')&.first&.strip }
        if steps.uniq.length != steps.length
          params["processing_event"].delete("processing_activity")
          flash[:alert] = "Processing activity steps must be unique.  Please correct and try again."
        end
      end
    end
  end
end
