class SubmissionsController < ApplicationController

  load_and_authorize_resource

  def new
    session[:submission_params] ||= {}
    @submission = Submission.new(session[:submission_params])
    @submission.current_step = session[:submission_step]
  end

  def create
    session[:submission_params].deep_merge!(submission_params) if params[:submission]
    @submission = Submission.new(session[:submission_params])
    @submission.current_step = session[:submission_step]
    if @submission.valid?
      if params[:previous_button]
        @submission.previous_step
      elsif @submission.last_step?
        @submission.save if @submission.all_valid?
      else
        @submission.next_step
      end
      session[:submission_step] = @submission.current_step
    end
    if @submission.new_record?
      render 'new'
    else
      session[:submission_step] = session[:submission_params] = nil
      flash[:notice] = 'Submission completed.'
      redirect_to @submission
    end
  end

  def show
    @submission = Submission.find(params[:id])
    @institution = Institution.find(@submission.institution_id)
    @object = ActiveFedora::Base.find(@submission.object_id)
  end

  private

  def submission_params
    params.fetch(:submission, {}).permit(:institution_id, :object_id)
  end

end
