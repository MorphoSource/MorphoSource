class SubmissionsController < ApplicationController

  load_and_authorize_resource

  def new
    @curation_concern = Media.new
  end

  def create
    if @submission.valid?
      redirect_to polymorphic_path([main_app, :new, :hyrax, :parent, 'media'], parent_id: @submission.find_parent_work)
    else
      render :new
    end
  end

  private

  def submission_params
    params.require(:submission).permit(:find_parent_work)
  end

end
