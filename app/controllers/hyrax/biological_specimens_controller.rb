# Generated via
#  `rails generate hyrax:work BiologicalSpecimen`
module Hyrax
  # Generated controller for BiologicalSpecimen
  class BiologicalSpecimensController < ApplicationController
    # Adds Hyrax behaviors to the controller
    include Morphosource::CurationConcernControllerBehavior
    include Hyrax::WorksControllerBehavior
    include Morphosource::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Hyrax::ChildWorkRedirect
    include Morphosource::LinkedTeams::LinkedTeamsManagement
    self.curation_concern_type = ::BiologicalSpecimen
    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::BiologicalSpecimenPresenter

    before_action :record_original_organizations, only: :update
    before_action :check_idigbio_update, only: :update
    after_action :set_idigbio_update_notice, only: :update

    skip_authorize_resource only: :showcase

    # override the layout from WorksControllerBehavior
    def decide_layout
      layout = case action_name
               when 'show'
                 '1_column'
               when 'showcase'
                 'morphosource_2_columns'
               #when 'new'
               #  'morphosource_2_columns'
               when 'edit'
                 'morphosource_2_columns'
               else
                 'dashboard'
               end
      File.join(theme, layout)
    end

    def showcase
      @presenter = show_presenter.new(curation_concern_from_search_results, current_ability, request)
      render 'showcase', presenter: @presenter
    end

    # overriding action methods from works_controller_behavior.rb
    def edit
      build_form
      @presenter = show_presenter.new(curation_concern_from_search_results, current_ability, request)
      #@presenter.get_organization_data
      @countries_service = Morphosource::CountriesService.new
      @new_taxonomy_submit_submissions_url = '/submissions/new_taxonomy_submit'
      @new_taxonomy_form = Hyrax::WorkFormService.build(::Taxonomy.new, current_ability, self)
      render 'edit', presenter: @presenter
    end

    def new
      curation_concern.depositor = current_user.user_key
      curation_concern.admin_set_id = admin_set_id_for_new
      build_form
      #@presenter = show_presenter.new(curation_concern_from_search_results, current_ability, request)
      #@presenter.get_organization_data
      render '/hyrax/base/new' #, presenter: @presenter
    end

    def update
      create_gbif_taxonomies
      if actor.update(actor_environment)
        update_media_team_access
        update_po_team_access
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

    def check_idigbio_update
      @idigbio_record_found = false
      if params[:biological_specimen].present?
        if (param_occ_id = params[:biological_specimen][:occurrence_id]).present? && 
          (curation_concern.occurrence_id&.first != param_occ_id)
          occurrence_id_results = Morphosource::IDigBio.search({'occurrenceid' => param_occ_id})
          @idigbio_record_found = (occurrence_id_results[:status] == :success && occurrence_id_results[:data].length > 0)
        end
      end
    end

    def set_idigbio_update_notice
      if @idigbio_record_found
        flash[:notice] = "The specimen has been updated to match the iDigBio record."
      end
    end

    private

    def create_gbif_taxonomies
      if params[:biological_specimen].present? && params[:biological_specimen][:taxonomy_id].present?
        params[:biological_specimen][:taxonomy_id].map! do |t_id|
          t_id.include?('gbif:') && (new_t_id = new_gbif_taxonomy(t_id)) ? new_t_id : t_id
        end
      end
    end

    def new_gbif_taxonomy(t_id)
      gbif_key = t_id.sub!('gbif:', '')
      gbif_params = ActionController::Parameters.new(
          Morphosource::GbifSearchService.taxonomy_params_from_gbif(gbif_key))
      taxonomy_params = Hyrax::TaxonomyForm.model_attributes(gbif_params)
      taxonomy_params.merge!({ visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC })
      curation_concern = Taxonomy.new
      env = Hyrax::Actors::Environment.new(curation_concern, current_ability, taxonomy_params)
      Hyrax::CurationConcern.actor.create(env)
      curation_concern.id
    end

    def old_orgs
      @original_organizations
    end

    def new_orgs
      ActiveFedora::Base.find(Array(@curation_concern.organization_id))
    end

    def occurrence_id_changed?
      params[:existing_occurrence_id] != curation_concern.occurrence_id&.first
    end

  end
end
