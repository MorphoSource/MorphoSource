# Generated via
#  `rails generate hyrax:work Device`
# Modified to use DeviceResource
module Hyrax
  # Generated controller for Device
  class DevicesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::ChildWorkRedirect

    before_action :find_organization, only: [:new, :create, :edit, :update]
    before_action :authorize_organization, only: [:new, :create, :edit, :update]

    skip_authorize_resource only: :show

    self.curation_concern_type = ::DeviceResource
    # Use a Valkyrie aware form service to generate Valkyrie::ChangeSet style
    # forms.
    self.work_form_service = Morphosource::FormFactory.new(self)
    
    with_themed_layout :decide_layout

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::DevicePresenter

    # Override default Valkyrie create work transaction
    # registered in config/initializers/transactions.rb
    self.create_valkyrie_work_action.transaction_name = "device_change_set.create_work"

    configure_blacklight do |config|
      config.max_per_page = 1000000
    end

    def decide_layout
      layout = case action_name
               when 'show'
                 'morphosource_2_columns'
               else
                 'morphosource_1_column'
               end
      File.join(theme, layout)
    end

    def show
      @device_media_ids = viewable_device_media_ids
      super
    end

    def new
      @curation_concern.organization_id = assign_organization_id
      @curation_concern.visibility = 'open' # default all new devices to open
      super
    end

    private

    # Override default Valkyrie update work transaction
    def update_valkyrie_work
      form = build_form
      return after_update_error(form_err_msg(form)) unless form.validate(params[hash_key_for_curation_concern])

      result =
        transactions['device_change_set.update_work']
        .with_step_args(
          'device_change_set.set_organization_id' => { attributes: form.input_params },
          'work_resource.save_acl' => { permissions_params: form.input_params["permissions"] }
        ).call(form)
      @curation_concern = result.value_or { return after_update_error(transaction_err_msg(result)) }
      after_update_response
    end

    def viewable_device_media_ids
      device_media = Morphosource::DeviceMediaSearchService.new(self, params['id']).search_results
      return [] unless device_media.present?
      ids = device_media.map{|d| d.id}
      return ids if current_ability.current_user.admin?
      return ids.select { |id| current_ability.can?(:read, id) }
    end

    # get the organization id:
    # from organization_id when new,
    # from work_parents_attributes when create or update,
    # from the device solr record on edit
    def find_organization
      organization_id = (
        params["organization_id"] ||
        params.dig("device","work_parents_attributes")&.permit!&.to_h&.values&.first&.dig("id") ||
        params.dig("device", "organization_id")&.first ||
        ::SolrDocument.where({"id" => params['id']})&.first&.to_h&.dig("organization_id_ssim")&.first
      )
      @organization = ::SolrDocument.where({"id" => organization_id})&.first
    end

    # for new device records when coming from an organization collection
    # only admins are allowed to create devices without organizations
    def assign_organization_id
      @organization.present? ? [@organization.id] : []
    end

    def after_create_response
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
