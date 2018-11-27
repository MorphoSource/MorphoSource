class SubmissionsController < ApplicationController

  load_and_authorize_resource

  def new
    session[:submission_params] ||= {}
    @submission = Submission.new(session[:submission_params])
    @submission.current_step = Submission.step(session[:submission_step])
  end

  def create
    # TODO: In serious need of refactoring
    if params[:start_over]
      session[:submission_step] = session[:submission_params] = nil
      redirect_to new_submission_path
    else
      session[:submission_params].deep_merge!(submission_params) if params[:submission]
      @submission = Submission.new(session[:submission_params])
      @submission.current_step = Submission.step(session[:submission_step])
      if params[:previous_button]
        @submission.step_back
      elsif @submission.valid?
        if @submission.last_step?
          @submission.save if @submission.all_valid?
          redirect_to [ main_app, :new, :hyrax, :parent, 'media', parent_id: @submission.imaging_event_id ]
        else
          @submission.step_forward
        end
      end
      session[:submission_step] = @submission.current_step.name
      if @submission.new_record?
        render 'new'
      else
        session[:submission_step] = session[:submission_params] = nil
      end
    end
  end

  private

  def submission_params
    params.fetch(:submission, {}).permit(:institution_id, :object_id, :imaging_event_id)
  end

end
