# Generated via
#  `rails generate hyrax:work Device`
module Hyrax
  # Generated controller for Device
  class DevicesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::ChildWorkRedirect

    before_action :authorize_admin, only: [:new, :create]
    before_action :find_organization, only: [:new, :create, :edit, :update]
    before_action :authorize_organization, only: [:new, :create, :update]

    skip_authorize_resource only: :show

    self.curation_concern_type = ::Device
    with_themed_layout :decide_layout

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::DevicePresenter

    def decide_layout
      layout = case action_name
               when 'show'
                 'morphosource_2_columns'
               else
                 'morphosource_1_column'
               end
      File.join(theme, layout)
    end

    def new
      @curation_concern.organization_id = assign_organization_id
      @curation_concern.visibility = 'open' # default all new devices to open
      super
    end

    private

    # get the organization id:
    # from organization_id when new,
    # from work_parents_attributes when create or update,
    # from the device solr record on edit
    def find_organization
      organization_id = (
        params["organization_id"] ||
        params.dig("device","work_parents_attributes")&.permit!&.to_h&.values&.first&.dig("id") ||
        params.dig("device", "organization_id")&.first ||
        ::SolrDocument.where("id" => params['id'])&.first&.to_h&.dig("organization_id_ssim")&.first
      )
      @organization = ::SolrDocument.where("id" => organization_id)&.first
    end

    # for new device records when coming from an organization collection
    # only admins are allowed to create devices without organizations
    def assign_organization_id
      @organization.present? ? [@organization.id] : []
    end

    def after_create_response
      curation_concern.update_index if curation_concern.id.present?
      respond_to do |wants|
        wants.html do
          flash[:notice] = t('hyrax.devices.create.after_create_html', device_name: "#{curation_concern.creator.first} #{curation_concern.title.first}")
          if @organization.present? && @organization.organization_collection?
            redirect_to main_app.organization_devices_path(@organization)
          else
            redirect_to [main_app, curation_concern]
          end
        end
        wants.json { render :show, status: :created, location: polymorphic_path([main_app, curation_concern]) }
      end
    end

    def after_update_response
      respond_to do |wants|
        wants.html do
          if @organization.present? && @organization.organization_collection?
            redirect_to main_app.organization_devices_path(@organization)
          else
            redirect_to [main_app, curation_concern], notice: "Device \"#{curation_concern}\" successfully updated."
          end
        end
        wants.json { render :show, status: :ok, location: polymorphic_path([main_app, curation_concern]) }
      end
    end

    def authorize_admin
      redirect_to root_path and return unless current_user&.admin?
    end

    def authorize_organization
      return true if current_user&.admin?
      raise CanCan::AccessDenied unless organization_editor?
    end

    def organization_editor?
      return false unless @organization.present?

      organization_groups = ["#{@organization.id}_managers", "#{@organization.id}_editors"]
      (organization_groups & current_user&.groups).any?
    end
  end
end
