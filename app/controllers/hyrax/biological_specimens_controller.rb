# Generated via
#  `rails generate hyrax:work BiologicalSpecimen`
module Hyrax
  # Generated controller for BiologicalSpecimen
  class BiologicalSpecimensController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Morphosource::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Hyrax::ChildWorkRedirect
    include Morphosource::LinkedTeams::LinkedTeamsManagement
    self.curation_concern_type = ::BiologicalSpecimen
    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::BiologicalSpecimenPresenter

    before_action :record_original_parents, only: :update

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
      @new_organization_submit_submissions_url = '/submissions/new_organization_submit'
      @new_organization_form = Hyrax::WorkFormService.build(::Organization.new, current_ability, self)
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

    private

    def create_gbif_taxonomies
      if params[:biological_specimen] && params[:biological_specimen][:work_parents_attributes]
        params[:biological_specimen][:work_parents_attributes].each do |wpa_id, wpa_val|
          if wpa_val[:id].include? 'gbif:'
            taxonomy_id = new_gbif_taxonomy(wpa_val[:id])
            wpa_val[:id] = taxonomy_id if taxonomy_id.present?
          end
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
      select_organizations(@original_parents)
    end

    def new_orgs
      select_organizations(@curation_concern.member_of)
    end
  end
end
