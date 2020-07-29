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

    # Overriding WorksControllerBehavior to add modality validation
    # Could not do this as an ActiveModel validation because parents are not added until after create
    def create
      if imaging_event_modality_valid? && actor.create(actor_environment)
        after_create_response
     else
       respond_to do |wants|
         wants.html do
           build_form
           render 'new', status: :unprocessable_entity
         end
         wants.json { render_json_response(response_type: :unprocessable_entity, options: { errors: curation_concern.errors }) }
       end
      end
    end

    def update
      if imaging_event_modality_valid? && actor.update(actor_environment)
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

    def update_media_physical_object_ids
      @curation_concern.descendants.select { |d| d.class == Media }.each { |m| m.update_physical_object_id }
    end

    def imaging_event_modality_valid?
      parent_devices = []
      if params['imaging_event']['work_parents_attributes'].present?
        params['imaging_event']['work_parents_attributes'].values.map do |v|
          if Device.where('id' => v['id']).present?
            parent_devices << Device.find(v['id'])
          end
        end
      end
      if parent_devices.empty?
        # if there is no parent device, no need to compare modalities.
        return true
      end
      parent_modalities = parent_devices.map{|d| d.modality.to_a}.flatten.uniq
      if parent_modalities.include?(params['imaging_event']['ie_modality'])
        return true
      else
        curation_concern.errors.add(:base, "Invalid modality \"#{params['imaging_event']['ie_modality']}\" for Imaging Event. Modality must match one of the following parent device modalities: #{parent_modalities.join(', ')}")
        return false
      end
    end

    def old_specimens
      select_specimens(@original_parents)
    end

    def new_specimens
      select_specimens(@curation_concern.member_of)
    end
  end
end
