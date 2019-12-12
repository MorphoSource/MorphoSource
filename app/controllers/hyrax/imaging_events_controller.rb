# Generated via
#  `rails generate hyrax:work ImagingEvent`
module Hyrax
  # Generated controller for ImagingEvent
  class ImagingEventsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Hyrax::ChildWorkRedirect
    self.curation_concern_type = ::ImagingEvent

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ImagingEventPresenter
    
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
    def imaging_event_modality_valid?
      parent_devices = []
      if params['imaging_event']['work_parents_attributes'].present?
        params['imaging_event']['work_parents_attributes'].values.map do |v| 
          if Device.where('id' => v['id']).present?
            parent_devices << Device.find(v['id'])
          end
        end
      else
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

  end
end
