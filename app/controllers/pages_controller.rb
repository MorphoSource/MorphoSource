class PagesController < ApplicationController
  load_and_authorize_resource except: [:show]
  with_themed_layout 'morphosource_dashboard'

  before_action :build_breadcrumbs, only: [:new, :edit]

  def show
    @page = Page.find_by!(slug: params[:slug])

    if @page.docs? && !(params[:page_type] == 'docs')
      redirect_to docs_path(@page) and return
    end

    authorize! :manage, @page if !@page.published?
    render layout: 'hyrax/morphosource_1_column'
  end

  def new
    @page = Page.new
  end

  def create
    @page = Page.new(page_params)
    if @page.save
      redirect_to @page, notice: 'Page was successfully created.'
    else
      flash[:alert] = @page.errors.full_messages.join(', ')
      render :new
    end
  end

  def edit
    @page = Page.find_by!(slug: params[:slug])
  end

  def update
    @page = Page.find_by!(slug: params[:slug])
    if @page.update(page_params)
      redirect_to @page, notice: 'Page was successfully updated.'
    else
      flash[:alert] = @page.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy
    @page = Page.find_by!(slug: params[:slug])
    @page.destroy
    redirect_to admin_pages_path, notice: 'Page was successfully destroyed.'
  end

  private

  def page_params
    params.require(:page).permit(:page_type, :slug, :title, :visibility, :content)
  end

  def build_breadcrumbs
    # These breadcrumbs are for the dashboard edit/create actions
    add_breadcrumb t(:'hyrax.controls.home'), root_path
    add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
    add_breadcrumb_for_controller
    add_breadcrumb_for_action
  end

  def add_breadcrumb_for_controller
    add_breadcrumb I18n.t(:'hyrax.admin.sidebar.simple_pages'), admin_pages_path
  end

  def add_breadcrumb_for_action
    case action_name
    when 'edit'.freeze
      add_breadcrumb 'Edit Page', request.path
    when 'new'.freeze
      add_breadcrumb 'New Page', request.path
    end
  end

end