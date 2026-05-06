# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource ImagingEventResource`
module Hyrax
  # Generated controller for ImagingEventResource
  class ImagingEventResourcesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Morphosource::WorksControllerBehavior
    include Hyrax::ChildWorkRedirect
    include Morphosource::LinkedTeams::LinkedTeamsManagement

    skip_authorize_resource only: :media_owner_update

    self.curation_concern_type = ::ImagingEventResource
    self.show_presenter = Hyrax::ImagingEventPresenter

    before_action :record_original_objects, only: :update

    # Use a Valkyrie aware form service to generate Valkyrie::ChangeSet style
    # forms.
    self.work_form_service = Hyrax::FormFactory.new

    self.create_valkyrie_work_action.transaction_name = "imaging_event_change_set.create_work"

    def create
      # ImagingEventResource titles are auto-generated (IE<id>: <description>).
      # Inject a placeholder so basic_metadata title validation passes.
      params[:imaging_event_resource] ||= {}
      params[:imaging_event_resource][:title] ||= ['new imaging event']
      super
    end

    def update
      # If the physical object association changed, re-record originals so
      # update_media_team_access can diff old vs new organizations.
      record_original_objects if po_changed

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

      super
    end

    # Authorizes a media owner to trigger an update on this imaging event
    # (e.g. to propagate team access changes from a media edit form).
    #
    # Uses Media#imaging_event to traverse the ancestor chain (IE → PE → Media),
    # since ImagingEventResource#media only returns direct member_ids and Media is
    # typically a grandchild (through ProcessingEvent), not a direct member.
    def media_owner_update
      media = begin
        ::Media.find(params["media_id"]) if params["media_id"].present?
      rescue ::ActiveFedora::ObjectNotFoundError, Ldp::Gone
        nil
      end

      if (
        media.present? &&
        media.imaging_event&.id.to_s == curation_concern.id.to_s &&
        current_user.can?(:edit, params["media_id"])
      )
        update
      else
        respond_to do |wants|
          wants.html { redirect_to main_app.root_url, alert: "Unauthorized." }
          wants.json { render_json_response(response_type: :forbidden) }
        end
      end
    end

    def po_changed
      @po_changed ||= begin
        if params[:imaging_event_resource] && params[:imaging_event_resource][:physical_object_id]
          (curation_concern.physical_object_id != params[:imaging_event_resource][:physical_object_id])
        else
          false
        end
      end
    end

    private

      # Use the custom imaging event update transaction instead of the Hyrax default.
      def update_valkyrie_work
        form = build_form
        return after_update_error(form_err_msg(form)) unless form.validate(params[hash_key_for_curation_concern])

        result =
          transactions['imaging_event_change_set.update_work']
          .with_step_args('work_resource.save_acl' => { permissions_params: form.input_params["permissions"] })
          .call(form)
        @curation_concern = result.value_or { return after_update_error(transaction_err_msg(result)) }
        after_update_response
      end

      # Override LinkedTeamsManagement#record_original_objects to use the
      # mixed Fedora/Valkyrie lookup provided by ImagingEventResource#objects.
      def record_original_objects
        @original_objects = curation_concern.objects
      end

      def find_all_media
        @media = curation_concern.media
      end

      # Inject update_media_team_access into the Valkyrie update success path.
      # update_valkyrie_work (from Hyrax::WorksControllerBehavior) calls
      # after_update_response on success; we hook in here rather than duplicating
      # update_valkyrie_work's transaction logic.
      #
      # Override the JSON response to avoid hyrax/base/show.json.jbuilder, which
      # attempts a Wings::ActiveFedoraConverter conversion that fails for
      # ImagingEventResource (not registered in Wings).
      def after_update_response
        update_media_team_access
        respond_to do |wants|
          wants.html { redirect_to [main_app, curation_concern], notice: "Work \"#{curation_concern}\" successfully updated." }
          wants.json { render json: { id: curation_concern.id.to_s }, status: :ok }
        end
      end

      # FailedSubmissionFormWrapper requires permitted_params/build_permitted_params,
      # which Valkyrie change sets don't provide. Hyrax documents rebuild_form as
      # "Required for ActiveFedora::Base objects only", so skip it here.
      def rebuild_form(_original_input_params = nil); end

      # Guard against nil when the imaging_event_resource params key is absent
      # (e.g. a minimal update that doesn't include the work hash).
      # LinkedTeamsManagement#parents_attributes does params[work_type][...] without
      # a nil check, which raises NoMethodError when params[work_type] is nil.
      def parents_attributes
        params[work_type]&.[](:work_parents_attributes)
      end

      def old_physical_objects
        select_physical_objects(@original_objects)
      end

      # Use postgres_service + explicit AF fallback rather than
      # ActiveFedora::Base.find, because physical objects may be either
      # Fedora-backed or Valkyrie-backed in the transitional environment.
      def new_physical_objects
        Array(curation_concern.physical_object_id).filter_map do |id|
          Hyrax.query_service.postgres_service.find_by(id: Valkyrie::ID.new(id))
        rescue Valkyrie::Persistence::ObjectNotFoundError
          begin
            ActiveFedora::Base.find(id)
          rescue ::ActiveFedora::ObjectNotFoundError, Ldp::Gone
            nil
          end
        end
      end

  end
end
