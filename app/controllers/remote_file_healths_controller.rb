class RemoteFileHealthsController < ApplicationController
  before_action :set_remote_file_health, only: [:show, :edit, :update, :destroy]

  # GET /remote_file_healths
  # GET /remote_file_healths.json
  def index
    @remote_file_healths = RemoteFileHealth.all
  end

  # GET /remote_file_healths/1
  # GET /remote_file_healths/1.json
  def show
  end

  # GET /remote_file_healths/new
  def new
    @remote_file_health = RemoteFileHealth.new
  end

  # GET /remote_file_healths/1/edit
  def edit
  end

  # POST /remote_file_healths
  # POST /remote_file_healths.json
  def create
    @remote_file_health = RemoteFileHealth.new(remote_file_health_params)

    respond_to do |format|
      if @remote_file_health.save
        format.html { redirect_to @remote_file_health, notice: 'Remote file health was successfully created.' }
        format.json { render :show, status: :created, location: @remote_file_health }
      else
        format.html { render :new }
        format.json { render json: @remote_file_health.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /remote_file_healths/1
  # PATCH/PUT /remote_file_healths/1.json
  def update
    respond_to do |format|
      if @remote_file_health.update(remote_file_health_params)
        format.html { redirect_to @remote_file_health, notice: 'Remote file health was successfully updated.' }
        format.json { render :show, status: :ok, location: @remote_file_health }
      else
        format.html { render :edit }
        format.json { render json: @remote_file_health.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /remote_file_healths/1
  # DELETE /remote_file_healths/1.json
  def destroy
    @remote_file_health.destroy
    respond_to do |format|
      format.html { redirect_to remote_file_healths_url, notice: 'Remote file health was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_remote_file_health
      @remote_file_health = RemoteFileHealth.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def remote_file_health_params
      params.require(:remote_file_health).permit(:media, :status, :details)
    end
end
