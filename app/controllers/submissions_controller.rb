class SubmissionsController < ApplicationController

  load_and_authorize_resource

  def new
    session[:submission_params] ||= {}
    @submission = Submission.new(session[:submission_params])
    @submission.current_step = Submission.step(session[:submission_step])
  end

  def create
    if params[:start_over]
      start_over
    else
      reinstantiate_submission
      if params[:previous_button]
        step_back
      else
        if @submission.valid?
          valid_submission
        else
          render 'new'
        end
      end
    end
  end

  private

  def clear_session_submission_settings
    session[:submission_step] = session[:submission_params] = nil
  end

  def finish_submission
    if @submission.all_valid?
      clear_session_submission_settings
      redirect_to [ main_app, :new, :hyrax, :parent, 'media', parent_id: @submission.imaging_event_id ]
    else
      session[:submission_step] = @submission.current_step.name
      render 'new'
    end
  end

  def reinstantiate_submission
    session[:submission_params].deep_merge!(submission_params) if params[:submission]
    @submission = Submission.new(session[:submission_params])
    @submission.current_step = Submission.step(session[:submission_step])
  end

  def start_over
    clear_session_submission_settings
    redirect_to new_submission_path
  end

  def step_back
    @submission.step_back
    session[:submission_step] = @submission.current_step.name
    render 'new'
  end

  def step_forward
    @submission.step_forward
    session[:submission_step] = @submission.current_step.name
    render 'new'
  end

  def submission_params
    params.fetch(:submission, {}).permit(:institution_id, :object_id, :imaging_event_id)
  end

  def valid_submission
    if @submission.last_step?
      finish_submission
    else
      step_forward
    end
  end

end
