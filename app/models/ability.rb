class Ability
  include Hydra::Ability

  include Morphosource::Ability
  self.ability_logic += [:everyone_can_create_curation_concerns]

  # Define any customized permissions here.
  def custom_permissions
    # Limits deleting objects to a the admin user
    #
    # if current_user.admin?
    #   can [:destroy], ActiveFedora::Base
    # end
    if current_user.admin?
      can [:create, :show, :add_user, :remove_user, :index, :edit, :update, :destroy], Role
    end

    # Limits creating new objects to a specific group
    #
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end

    if registered_user?
      can [ :create, :stage_biological_specimen, :stage_cultural_heritage_object, :stage_device, :stage_imaging_event, :stage_organization, :stage_device_organization, :stage_media, :stage_processing_event, :stage_cho, :stage_taxonomy, :new_organization, :new_organization_submit, :new_taxonomy, :new_taxonomy_submit, :new_device_submit ], Submission
      can [ :zip ], Media
      can [ :showcase ], BiologicalSpecimen
      can [ :showcase ], CulturalHeritageObject
      can [ :showcase ], Media
    end

  end
end
