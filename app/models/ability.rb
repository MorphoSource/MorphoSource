class Ability
  include Hydra::Ability

  include Morphosource::Ability

  # Define any customized permissions here.
  def custom_permissions

    if current_user.admin?
      can [:create, :show, :add_user, :remove_user, :index, :edit, :update, :destroy], Role
      can [:index], ::User
    end

    # Limits creating new objects to admins and contributors
    if admin? || contributor?
      can [:create], ActiveFedora::Base
      can [ :new, :create, :stage_biological_specimen, :stage_biological_specimen_from_idigbio, :stage_cultural_heritage_object, :stage_device, :stage_imaging_event, :stage_organization, :stage_device_organization, :stage_media, :stage_processing_event, :stage_cho, :stage_taxonomy, :new_organization, :new_organization_submit, :new_taxonomy, :new_taxonomy_submit, :new_device_submit, :new_processing_event_submit ], Submission
    end

    if admin? || batch_upload_contributor?
      can [ :new ], BatchUpload
    end

    if registered_user?
      can [ :zip ], Media
      can [ :show ], ::User
    end
  end
end
