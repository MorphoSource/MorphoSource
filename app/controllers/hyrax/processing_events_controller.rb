# Generated via
#  `rails generate hyrax:work ProcessingEvent`
module Hyrax
  # Generated controller for ProcessingEvent
  class ProcessingEventsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Hyrax::ChildWorkRedirect
    self.curation_concern_type = ::ProcessingEvent

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ProcessingEventPresenter


    private

      def after_update_response
        # todo: might need to check for errors here?
        respond_to do |wants|
          msg = { :status => "ok", :message => "success", :html => "" }
          wants.js { render :json => msg }
          wants.html { redirect_to [main_app, curation_concern], notice: "Work \"#{curation_concern}\" successfully updated." }

        end
      end

  end
end
