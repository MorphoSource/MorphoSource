Rails.application.routes.draw do
  ### MODIFIED AND NEW HYRAX MODULE ROUTES ###
  scope module: :hyrax do
    ### CURATION CONCERN RESOURCES ###
    # Allow both concern/resource/ and resource/ routes

    # Media
    get 'media/:id', to: 'media#showcase'
    get 'media/:id/edit', to: 'media#edit', as: :media_showcase_edit
    get 'media/:id/thumbnail', to: 'media#thumbnail'
    get 'concern/media/:id', to: 'media#showcase', as: :media_showcase
    get 'concern/media/:id/characterize', to: 'media#characterize', as: :media_characterize
    get 'concern/media/:id/derive', to: 'media#create_derivatives', as: :media_create_derivatives
    put 'concern/media/:id/mint_doi', to: 'media#mint_doi', as: :media_mint_doi
    get 'concern/media/:id/temporary_link/:token', to: 'media#showcase', as: 'media_showcase_temporary_link'
    get 'concern/media/:id/thumbnail', to: 'media#thumbnail'
    get 'concern/media/:id/modal/archive-contents', to: 'media#modal_file_archive_contents'
    get 'concern/parent/:parent_id/media/:id', to: 'media#showcase'

    # Biological specimens
    get 'biological_specimens/:id', to: 'biological_specimens#showcase'
    get 'concern/biological_specimens/new', to: 'biological_specimens#new'
    get 'concern/biological_specimens/:id', to: 'biological_specimens#showcase', as: 'specimen_showcase'
    get 'concern/parent/:parent_id/biological_specimens/:id', to: 'biological_specimens#showcase'

    # Cultural heritage objects
    get 'cultural_heritage_objects/:id', to: 'cultural_heritage_objects#showcase'
    get 'concern/cultural_heritage_objects/new', to: 'cultural_heritage_objects#new'
    get 'concern/cultural_heritage_objects/:id', to: 'cultural_heritage_objects#showcase', as: 'cho_showcase'
    get 'concern/parent/:parent_id/cultural_heritage_objects/:id', to: 'cultural_heritage_objects#showcase'

    # Organizations (will eventually be deprecated in favor of organization collections
    get 'concern/organizations/new', to: 'organizations#new'
    get 'concern/organizations/:id', to: 'organizations#show', as: :show_organization
    get 'concern/organizations/specimens/:id', to: 'organizations#specimens'
    get 'concern/organizations/chos/:id', to: 'organizations#chos'
    # Search for organizations without team id
    get 'unlinked_organizations', to: 'organizations#unlinked_organizations'
    # media pagination
    get 'organization_paging/concern/organizations/:id', to: redirect { |params, request| "concern/organizations/#{request.params[:id]}?#{request.params.to_query}" }
    # bso pagination
    get 'organization_paging/concern/organizations/specimens/:id', to: redirect { |params, request| "concern/organizations/#{request.params[:id]}?#{request.params.to_query}" }
    # cho pagination
    get 'organization_paging/concern/organizations/chos/:id', to: redirect { |params, request| "concern/organizations/#{request.params[:id]}?#{request.params.to_query}" }

    ### PAGING ROUTES FOR MY PROJECTS AND TEAMS and BROWSE PROJECTS AND TEAMS ###

    # My teams/projects paging
    get 'my_projects_paging/dashboard/my/teams', to: redirect { |params, request| "/dashboard/my/projects/?#{request.params.to_query}" }
    get 'my_teams_paging/dashboard/my/teams', to: redirect { |params, request| "/dashboard/my/teams/?#{request.params.to_query}" }

    # Browse teams/projects paging
    get 'browse_projects_paging/browse/teams', to: redirect { |params, request| "/browse/projects/?#{request.params.to_query}" }
    get 'browse_teams_paging/browse/teams', to: redirect { |params, request| "/browse/teams/?#{request.params.to_query}" }

    ### DASHBOARD ###

    put 'dashboard/transfers/decide', controller: :transfers, action: :batch_decide_transfers, as: 'transfers_batch_decide'

    ### USERS ###

    # Make user account active/inactive
    post 'users/:id/make_active', to: 'users#make_user_active', as: 'make_active'
    post 'users/:id/make_inactive', to: 'users#make_user_inactive', as: 'make_inactive'

    # Admin sign in as user
    get 'users/:id/become', to: 'users#become', as: 'become_user'

    ### AJAX ROUTES FOR MEDIA OWNERS SUBMITTING UPDATES TO MEDIA-ASSOCIATED IE AND PE WORKS ###

    resources :processing_events do
      member do
        post 'media_owner_update'
        patch 'media_owner_update'
      end
    end

    resources :imaging_events do
      member do
        post 'media_owner_update'
        patch 'media_owner_update'
      end
    end

    ### NON-MODULE SCOPES ###

    scope :browse do
      resources :teams, only: [:index], controller: 'browse_teams', as: 'browse_teams'
      resources :projects, only: [:index], controller: 'browse_teams', as: 'browse_projects'
      resources :organizations, only: [:index], controller: 'browse_organizations', as: 'browse_organizations'
      resources :taxonomies, only: [:index, :children], controller: 'browse_taxonomies', as: 'browse_taxonomies'
      resources :media_types_and_modalities, only: [:index], action: :media_types_and_modalities, controller: 'browse', as: 'browse_media_types_and_modalities'
      resources :physical_object_types, only: [:index], action: :physical_object_types, controller: 'browse', as: 'browse_physical_object_types'
      resources :categories, only: [:index], action: :categories, controller: 'browse', as: 'browse_categories'
    end

    ### MODULE SCOPES ###

    scope module: :my, path: 'dashboard/my', as: 'my' do
      resources :teams, only: [:index], controller: 'teams'
      resources :projects, only: [:index], controller: 'teams'
    end
  end

  ### NEW MORPHOSOURCE ROUTES ###
  scope module: :morphosource do
    resources :tags, param: :tag, only: [:index, :show]
    get '/attachments/:id', to: 'attachments#show', as: 'attachment'
    get '/manifests/:id', to: 'manifests#show', as: 'manifest'

    # media ZIP downloads
    get '/download', to: 'media_downloads#show', as: 'media_download'
    # derivative (thumbnail and 3D/2D/AV preview) downloads
    get '/downloads/:id', to: 'derivative_downloads#show', as: 'download'

    # media download using url generated by API
    get '/download/from-api/:id', to: 'media_api_downloads#download', as: 'download_from_api'

    # ARK and DOI resolving routes
    get '/*ark_tag/*identifier', action: :resolve_ark, controller: :identifier_resolver, constraints: { ark_tag: 'ark:' }
    if ENV['CROSSREF_DOI_SHOULDER'].present? && ENV['CROSSREF_DOI_SHOULDER'].split('/')[0].present?
      get '/*doi_tag/*identifier', action: :resolve_doi, controller: :identifier_resolver, constraints: { doi_tag: ENV['CROSSREF_DOI_SHOULDER'].split('/')[0] }
    end

    # Temporary media access link
    post 'temporary_links/generate_link_for_media/:media_id', action: :create, controller: :temporary_media_access_links, as: 'temporary_media_access_link_create'
    delete 'temporary_links/revoke_media_link/:id', action: :destroy, controller: :temporary_media_access_links, as: 'temporary_media_access_link_destroy'

    # Temporary collection (project/team) media access link
    post 'temporary_links/generate_link_for_collection/:collection_id', action: :create, controller: :temporary_collection_access_links, as: 'temporary_collection_access_link_create'
    delete 'temporary_links/revoke_collection_link/:id', action: :destroy, controller: :temporary_collection_access_links, as: 'temporary_collection_access_link_destroy'

    ### COLLECTIONS AND COLLECTION SUBTYPES (TEAM, PROJECT, MEDIA LIST, SEQUENTIAL SECTION LIST, ORG COLLS) ###

    # Any collections/ routes will be redirected to correct collection sub-type
    get 'collections/:id', to: 'collections#show', as: 'collection'
    get 'collections/:id/about', to: 'collections#about'
    get 'collections/:id/facet/:id', to: 'collections#facet'

    # Collection CSV export routes for media downloads and media requests
    get 'teams/:id/media_downloads', to: 'collections#media_downloads', as: 'team_media_downloads'
    get 'teams/:id/media_requests', to: 'collections#media_requests', as: 'team_media_requests'
    get 'projects/:id/media_downloads', to: 'collections#media_downloads', as: 'project_media_downloads'
    get 'projects/:id/media_requests', to: 'collections#media_requests', as: 'project_media_requests'
    get 'media_lists/:id/media_downloads', to: 'collections#media_downloads', as: 'media_list_media_downloads'
    get 'media_lists/:id/media_requests', to: 'collections#media_requests', as: 'media_list_media_requests'
    get 'sequential_section_lists/:id/media_downloads', to: 'collections#media_downloads', as: 'sequential_section_list_media_downloads'
    get 'sequential_section_lists/:id/media_requests', to: 'collections#media_requests', as: 'sequential_section_list_media_requests'

    ### ADMIN TOOLS AND VIEWS ###
    scope module: :admin, path: 'admin' do
      # all background jobs
      get 'jobs', action: :index, controller: :background_jobs, as: 'admin_jobs'

      # all downloads
      get 'downloads', action: :index, controller: :downloads, as: 'admin_downloads'

      # all requests
      get 'requests', action: :index, controller: :requests, as: 'admin_requests'

      # remote file health dashboard
      get 'remote_file_health', action: :index, controller: :remote_file_healths, as: 'remote_file_health'
      get 'remote_file_health/verify_all', action: :verify_all, controller: :remote_file_healths, as: 'remote_file_health_verify_all'
      get 'remote_file_health/verify_media/:id', action: :verify_media, controller: :remote_file_healths, as: 'remote_file_health_verify_media'

      # contributor petitions
      get 'contributor_applications', action: :current_applications, controller: :contributor_petitions, as: 'admin_contributor_petitions'
      get 'contributor_applications_previous', action: :previous_applications, controller: :contributor_petitions, as: 'admin_contributor_petitions_previous'
      get 'contributor_applications_previous/(:id)', action: :update_application_decision, controller: :contributor_petitions, as: 'admin_update_contributor_petition_decision'
      patch 'contributor_applications/(:id)', action: :decide_petition, controller: :contributor_petitions, as: 'admin_contributor_petitions_decide'

      # fund codes
      get 'fund_codes/(:id)', action: :index, controller: :fund_codes, as: 'admin_fund_codes'
      post 'fund_codes', action: :create, controller: :fund_codes, as: 'admin_fund_codes_create'
      patch 'fund_codes/:id', action: :update, controller: :fund_codes, as: 'admin_fund_codes_update'
      delete 'fund_codes/:id', action: :delete, controller: :fund_codes, as: 'admin_fund_codes_delete'
      delete 'fund_codes/:id/attachments/:index', action: :delete_attachment, controller: :fund_codes, as: 'admin_fund_codes_delete_attachment'

      # data curation
      get 'data_curation', action: :index, controller: :data_curation, as: 'admin_data_curation'
      post 'data_curation/apply_permission_template', action: :apply_permission_template, controller: :data_curation, as: 'admin_apply_permission_template'
      get 'import_slides', action: :index, controller: :import_slides, as: 'admin_import_slides'
      post 'import_slides', action: :import_slides, controller: :import_slides, as: 'import_slides'
    end

    ### COLLECTION SHOW (NON-DASHBOARD) ###
    scope module: :collections do
      # Biological specimen and cultural heritage tab routes will be redirected to correct collection sub-type
      get 'collections/:id/biological_specimens', to: 'biological_specimens#show'
      get 'collections/:id/cultural_heritage_objects', to: 'cultural_heritage_objects#show'

      ### PROJECTS ###

      # Project general
      get 'projects/:id', to: 'projects#show', as: 'project'
      get 'projects/:id/biological_specimens', to: 'biological_specimens#show', as: 'project_specimens'
      get 'projects/:id/cultural_heritage_objects', to: 'cultural_heritage_objects#show', as: 'project_chos'
      get 'projects/:id/about', to: 'projects#about', as: 'project_about'
      get 'projects/:collection_id/facet/:id', to: 'projects#facet', as: 'project_media_facet'
      get 'projects/:collection_id/biological_specimens/facet/:id', to: 'biological_specimens#facet', as: 'project_specimens_facet'
      get 'projects/:collection_id/cultural_heritage_objects/facet/:id', to: 'cultural_heritage_objects#facet', as: 'project_chos_facet'
      get 'projects/:id/temporary_link/:token', to: 'projects#show', as: 'project_show_temporary_link'

      # Project CSV exports
      get 'projects/:id/media_export', to: 'projects#media_export_with_intersections_facet', as: 'project_media_export'
      get 'projects/:id/media_download_counts', to: 'projects#media_download_counts_with_intersections_facet', as: 'project_media_download_counts'
      get 'projects/:id/biological_specimens/objects_export', to: 'biological_specimens#objects_export', as: 'project_specimens_export'
      get 'projects/:id/cultural_heritage_objects/objects_export', to: 'cultural_heritage_objects#objects_export', as: 'project_chos_export'

      # Project redirects
      get 'projects/specimens/:id', to: redirect('projects/%{id}/biological_specimens')
      get 'projects/chos/:id', to: redirect('projects/%{id}/cultural_heritage_objects')

      ### TEAMS ###

      # Team general
      get 'teams/:id', to: 'teams#show', as: 'team'
      get 'teams/:id/biological_specimens', to: 'biological_specimens#show', as: 'team_specimens'
      get 'teams/:id/cultural_heritage_objects', to: 'cultural_heritage_objects#show', as: 'team_chos'
      get 'teams/:id/about', to: 'teams#about', as: 'team_about'
      get 'teams/:collection_id/facet/:id', to: 'teams#facet', as: 'team_media_facet'
      get 'teams/:collection_id/biological_specimens/facet/:id', to: 'biological_specimens#facet', as: 'team_specimens_facet'
      get 'teams/:collection_id/cultural_heritage_objects/facet/:id', to: 'cultural_heritage_objects#facet', as: 'team_chos_facet'

      # Team CSV exports (some specific to org-linked teams)
      get 'teams/:id/media_export', to: 'teams#media_export_with_intersections_facet', as: 'team_media_export'
      get 'teams/:id/media_download_counts', to: 'teams#media_download_counts_with_intersections_facet', as: 'team_media_download_counts'
      get 'teams/:id/biological_specimens/objects_export', to: 'biological_specimens#objects_export', as: 'team_specimens_export'
      get 'teams/:id/cultural_heritage_objects/objects_export', to: 'cultural_heritage_objects#objects_export', as: 'team_chos_export'
      get 'teams/:id/media_projects', to: 'teams#media_projects', as: 'team_media_projects'
      get 'teams/:id/media_organization_transfer_status', to: 'teams#media_organization_transfer_status', as: 'team_media_organization_transfer_status'

      # Team redirects
      get 'teams/specimens/:id', to: redirect('teams/%{id}/biological_specimens')
      get 'teams/chos/:id', to: redirect('teams/%{id}/cultural_heritage_objects')

      ### ORGANIZATION COLLECTIONS ###

      # Object media tab
      get 'organizations/:id', to: 'organization_collections#show', as: 'organization'
      get 'organizations/:id', to: 'organization_collections#show', as: 'organization_collection'
      get 'organizations/:collection_id/facet/:id', to: 'organization_collections#facet', as: 'organization_media_facet'

      # Device media tab
      get 'organizations/:id/device-media', to: 'organization_collections/device_media#show', as: 'organization_device_media'
      get 'organizations/:collection_id/device-media/facet/:id', to: 'organization_collections/device_media#facet', as: 'organization_device_media_facet'

      # Specimens tab
      get 'organizations/:id/biological-specimens', to: 'organization_collections/physical_objects/biological_specimens#show', as: 'organization_specimens'
      get 'organizations/:collection_id/biological-specimens/facet/:id', to: 'organization_collections/physical_objects/biological_specimens#facet', as: 'organization_specimens_facet'

      # CHOs tab
      get 'organizations/:id/cultural-heritage-objects', to: 'organization_collections/physical_objects/cultural_heritage_objects#show', as: 'organization_chos'
      get 'organizations/:collection_id/cultural-heritage-objects/facet/:id', to: 'organization_collections/physical_objects/cultural_heritage_objects#facet', as: 'organization_chos_facet'

      # Devices tab
      get 'organizations/:id/devices', to: 'organization_collections/devices#show', as: 'organization_devices'
      get 'organizations/:collection_id/devices/facet/:id', to: 'organization_collections/devices#facet', as: 'organization_devices_facet'

      # About tab
      get 'organizations/:id/about', to: 'organization_collections#about', as: 'organization_about'

      # Object media CSV exports
      get 'organizations/:id/media_export', to: 'organization_collections#media_export_with_intersections_facet', as: 'organization_media_export'
      get 'organizations/:id/media_download_counts', to: 'organization_collections#media_download_counts_with_intersections_facet', as: 'organization_media_download_counts'
      get 'organizations/:id/media_downloads', to: 'organization_collections#media_downloads', as: 'organization_media_downloads'
      get 'organizations/:id/media_requests', to: 'organization_collections#media_requests', as: 'organization_media_requests'

      # Device media CSV exports
      get 'organizations/:id/device_media_export', to: 'organization_collections/device_media#media_export_with_intersections_facet', as: 'organization_device_media_export'
      get 'organizations/:id/device_media_download_counts', to: 'organization_collections/device_media#media_download_counts_with_intersections_facet', as: 'organization_device_media_download_counts'
      get 'organizations/:id/device_media_downloads', to: 'organization_collections/device_media#media_downloads', as: 'organization_device_media_downloads'
      get 'organizations/:id/device_media_requests', to: 'organization_collections/device_media#media_requests', as: 'organization_device_media_requests'

      # Other organizationl collection CSV exports
      get 'organizations/:id/biological_specimens/objects_export', to: 'organization_collections/physical_objects/biological_specimens#objects_export', as: 'organization_specimens_export'
      get 'organizations/:id/cultural_heritage_objects/objects_export', to: 'organization_collections/physical_objects/cultural_heritage_objects#objects_export', as: 'organization_chos_export'
      get 'organizations/:id/devices/devices_export', to: 'organization_collections/devices#devices_export', as: 'organization_devices_export'

      ### MEDIA LISTS ###

      # Media list general
      get 'media_lists/:id', to: 'media_lists#show', as: 'media_list'
      get 'media_lists/:id/biological_specimens', to: 'biological_specimens#show', as: 'media_list_specimens'
      get 'media_lists/:id/cultural_heritage_objects', to: 'cultural_heritage_objects#show', as: 'media_list_chos'
      get 'media_lists/:id/about', to: 'media_lists#about', as: 'media_list_about'
      get 'media_lists/:collection_id/facet/:id', to: 'media_lists#facet', as: 'media_list_media_facet'
      get 'media_lists/:collection_id/biological_specimens/facet/:id', to: 'biological_specimens#facet', as: 'media_list_specimens_facet'
      get 'media_lists/:collection_id/cultural_heritage_objects/facet/:id', to: 'cultural_heritage_objects#facet', as: 'media_list_chos_facet'
      get 'media_lists/:id/order_media', to: 'media_lists#order_media', as: 'media_list_order_media'
      get 'media_lists/:id/preview/:media_id', to: 'media_lists#preview', as: 'media_list_preview'

      # Media list CSV exports
      get 'media_lists/:id/media_export', to: 'media_lists#media_export_with_intersections_facet', as: 'media_list_media_export'
      get 'media_lists/:id/media_download_counts', to: 'media_lists#media_download_counts_with_intersections_facet', as: 'media_list_media_download_counts'
      get 'media_lists/:id/biological_specimens/objects_export', to: 'biological_specimens#objects_export', as: 'media_list_specimens_export'
      get 'media_lists/:id/cultural_heritage_objects/objects_export', to: 'cultural_heritage_objects#objects_export', as: 'media_list_chos_export'

      ### SEQUENTIAL SECTION LISTS ###

      # Despite scope being media_lists, this is for sequential_section_lists (which inherit from media lists)
      scope module: :media_lists do
        # Sequential section list general
        get 'sequential_section_lists/:id', to: 'sequential_section_lists#show', as: 'sequential_section_list'
        get 'sequential_section_lists/:id/about', to: 'sequential_section_lists#about', as: 'sequential_section_list_about'
        get 'sequential_section_lists/:collection_id/facet/:id', to: 'sequential_section_lists#facet', as: 'sequential_section_list_media_facet'

        # Sequential section list CSV exports
        get 'sequential_section_lists/:id/media_export', to: 'sequential_section_lists#media_export_with_intersections_facet', as: 'sequential_section_list_media_export'
        get 'sequential_section_lists/:id/media_download_counts', to: 'sequential_section_lists#media_download_counts_with_intersections_facet', as: 'sequential_section_list_media_download_counts'

        # Order media
        get 'sequential_section_lists/:id/order_media', to: 'sequential_section_lists#order_media', as: 'sequential_section_list_order_media'

        # Preview media
        get 'sequential_section_lists/:id/preview/:media_id', to: 'sequential_section_lists#preview', as: 'sequential_section_list_preview'
      end

      # Sequential section list object tab
      get 'sequential_section_lists/:id/biological_specimens', to: 'biological_specimens#show', as: 'sequential_section_list_specimens'
      get 'sequential_section_lists/:id/cultural_heritage_objects', to: 'cultural_heritage_objects#show', as: 'sequential_section_list_chos'
      get 'sequential_section_lists/:collection_id/biological_specimens/facet/:id', to: 'biological_specimens#facet', as: 'sequential_section_list_specimens_facet'
      get 'sequential_section_lists/:collection_id/cultural_heritage_objects/facet/:id', to: 'cultural_heritage_objects#facet', as: 'sequential_section_list_chos_facet'

      # Sequential section list object CSV exports
      get 'sequential_section_lists/:id/biological_specimens/objects_export', to: 'biological_specimens#objects_export', as: 'sequential_section_list_specimens_export'
      get 'sequential_section_lists/:id/cultural_heritage_objects/objects_export', to: 'cultural_heritage_objects#objects_export', as: 'sequential_section_list_chos_export'
    end

    ### DASHBOARD ###
    scope module: :dashboard do

      ### PROFILE ###
      get 'dashboard/profiles/:id', to: 'profiles#show', as: 'profile_show'
      get 'dashboard/profiles/:id/edit', to: 'profiles#edit', as: 'profile_edit'
      get 'dashboard/profiles/:id/edit_password', to: 'profiles#edit_password', as: 'profile_edit_password'
      get 'dashboard/profiles/:id/edit_profile_type', to: 'profiles#edit_profile_type', as: 'edit_profile_type'
      get 'dashboard/profiles/:id/generate_new_api_key', to: 'profiles#generate_new_api_key', as: 'profile_generate_new_api_key'
      put 'dashboard/profiles/:id', to: 'profiles#update'
      patch 'dashboard/profiles/:id', to: 'profiles#update'
      patch 'dashboard/profiles/:id/update_password', to: 'profiles#update_password', as: 'profile_update_password'
      patch 'dashboard/profiles/:id/update_profile_type', to: 'profiles#update_profile_type', as: 'update_profile_type'

      ### COLLECTION ROUTES NOT IN COLLECTIONS MODULE SCOPE ###

      # dashboard generic collections edit page
      get 'dashboard/collections/new', to: 'collections#new', as: 'new_collection'
      get 'dashboard/collections/:id', controller: :collections, action: :edit, as: 'collection_edit'
      get 'dashboard/collections/:id/edit', controller: :collections, action: :edit
      post 'dashboard/collections/:id', controller: :collection_members, action: :update_members, as: 'update_members'
      put 'dashboard/collections', to: 'collections#update'
      put 'dashboard/collections/:id', to: 'collections#update'
      patch 'dashboard/collections/:id', to: 'collections#update'
      delete 'dashboard/collections/:id', to: 'collections#destroy', as: 'destroy_collection'
      post 'dashboard/collections/:id/remove/:member_id', to: 'collections#remove_member', as: 'collection_remove_member'
      # Create project within team
      get 'collections/:parent_id/under', controller: 'nest_collections', action: 'create_collection_under', as: 'create_subcollection_under'

      # organization-team linkage functions (will eventually be deprecated)
      post 'dashboard/collections/:id/organizations', action: :link_organization, controller: :linked_teams, as: 'dashboard_collection_link_organization'
      post 'dashboard/collections/:id/unlink_organization', action: :unlink_organization, controller: :linked_teams, as: 'dashboard_collection_unlink_organization'
      patch 'dashboard/collections/:id/update_permissions', to: 'linked_teams#update_permissions', as: 'update_default_permissions'

      resources :collections, only: [:create]

      ### COLLECTION SUB-TYPES ###
      scope module: :collections, path: :dashboard do
        # Teams
        get 'teams/new', to: 'teams#new', as: 'new_team'
        get 'teams/:id', to: "teams#edit", as: "team_edit"
        get 'teams/:id/files', to: 'teams#files'
        get 'teams/:id/members', to: 'teams#members', as: 'team_members'
        get 'teams/:id/organization', to: 'teams#organization', as: 'team_organization'
        get 'teams/:id/projects', to: 'teams#projects', as: 'team_projects'
        post 'teams', to: 'teams#create'
        put 'teams', to: 'teams#update'
        put 'teams/:id', to: 'teams#update', as: 'update_team'
        patch 'teams/:id', to: 'teams#update'

        # Projects
        get 'projects/new', to: 'projects#new', as: 'new_project'
        get 'projects/:id', to: 'projects#edit', as: 'project_edit'
        get 'projects/:id/files', to: 'projects#files'
        get 'projects/:id/members', to: 'projects#members', as: 'project_members'
        post 'projects', to: 'projects#create'
        put 'projects', to: 'projects#update'
        put 'projects/:id', to: 'projects#update', as: 'update_project'
        patch 'projects/:id', to: 'projects#update'

        # Organization collections
        get 'organizations/new', to: 'organization_collections#new', as: 'new_organization'
        get 'organizations/:id', to: 'organization_collections#edit', as: 'organization_edit'
        get 'organizations/:id/edit', to: redirect('dashboard/organizations/%{id}')
        get 'organizations/:id/files', to: 'organization_collections#files'
        get 'organizations/:id/members', to: 'organization_collections#members', as: 'organization_members'
        get 'organizations/:id/permissions', to: 'organization_collections#permissions', as: 'organization_permissions'
        get 'organizations/:id/projects', to: 'organization_collections#projects', as: 'organization_projects'
        post 'organizations', to: 'organization_collections#create'
        put 'organizations', to: 'organization_collections#update'
        put 'organizations/:id', to: 'organization_collections#update', as: 'update_organization'
        patch 'organizations/:id', to: 'organization_collections#update'

        # Media lists
        get 'media_lists/new', to: 'media_lists#new', as: 'new_media_list'
        get 'media_lists/:id', to: 'media_lists#edit', as: 'media_list_edit'
        get 'media_lists/:id/edit', to: redirect('dashboard/media_lists/%{id}')
        get 'media_lists/:id/files', to: 'media_lists#files'
        get 'media_lists/:id/members', to: 'media_lists#members', as: 'media_list_members'
        post 'media_lists', to: 'media_lists#create'
        put 'media_lists', to: 'media_lists#update'
        put 'media_lists/:id', to: 'media_lists#update', as: 'update_media_list'
        patch 'media_lists/:id', to: 'media_lists#update'

        # Sequential section lists (in scope media_lists due to inheriting from media list)
        scope module: :media_lists do
          get 'sequential_section_lists/new', to: 'sequential_section_lists#new', as: 'new_sequential_section_list'
          get 'sequential_section_lists/:id', to: 'sequential_section_lists#edit', as: 'sequential_section_list_edit'
          get 'sequential_section_lists/:id/files', to: 'sequential_section_lists#files'
          get 'sequential_section_lists/:id/members', to: 'sequential_section_lists#members', as: 'sequential_section_list_members'
          post 'sequential_section_lists', to: 'sequential_section_lists#create'
          put 'sequential_section_lists', to: 'sequential_section_lists#update'
          put 'sequential_section_lists/:id', to: 'sequential_section_lists#update', as: 'update_sequential_section_list'
          patch 'sequential_section_lists/:id', to: 'sequential_section_lists#update'
        end
      end
    end

    ### PAGES AND ACTIONS FOR MY PAGES ###
    scope module: :my do
      # cart items
      post 'add_to_cart', action: :create, controller: :cart_items
      post 'batch_add_to_cart', action: :batch_create, controller: :cart_items
      get 'download_work', action: :download, controller: :cart_items

      # media cart
      post 'download_items', action: :download, controller: :media_carts, as: 'download_items'
      delete 'remove_from_cart', action: :destroy, controller: :media_carts, as: 'remove_items'

      # downloads
      post 'batch_create_items', action: :batch_create, controller: :downloads

      # requests
      put 'request_item', action: :request_item, controller: :requests, as: 'request_item'
      get 'request_again', action: :request_again, controller: :requests, as: 'request_again'
      put 'cancel_request', action: :cancel_request, controller: :requests, as: 'cancel_request'
      put 'move_to_cart', action: :move_to_cart, controller: :requests
      post 'request_work', action: :request_work, controller: :requests

      # request manager
      get 'dashboard/my/request_manager', action: :index, controller: :request_managers, as: 'request_manager'
      put 'approve_download', action: :approve_download, controller: :request_managers, as: 'approve_download'
      put 'clear_request', action: :clear_request, controller: :request_managers, as: 'clear_request'
      put 'deny_download', action: :deny_download, controller: :request_managers, as: 'deny_download'

      # previous requests
      get 'dashboard/my/previous_requests', action: :index, controller: :previous_requests, as: 'previous_requests'
      put 'edit_expiration', action: :edit_expiration, controller: :previous_requests, as: 'edit_expiration'

      # apply for contributor status
      get 'contribute', action: :index, controller: :contributor_petitions, as: 'user_contributor_petition'
      put 'submit_contributor_application', action: :create, controller: :contributor_petitions, as: 'user_contributor_petition_submit'
      patch 'update_contributor_application/(:id)', action: :update, controller: :contributor_petitions, as: 'user_contributor_petition_update'

      # search_collections
      get 'my/collections/search', to: 'collections/search_collections#search', as: 'search_my_collections'
    end

    ### PAGES AND ACTIONS WITH PATHS PRECEDED BY dashboard/my ###
    scope module: :my, path: 'dashboard/my', as: 'my' do
      # my curation concern pages
      resources :media, only: [:index], controller: 'media'
      resources :media, path: "media/:collection_id", only: [:index], controller: 'add_media', as: 'add_media'
      resources :specimens, only: [:index], controller: 'biological_specimens'
      resources :cultural_heritage_objects, only: [:index], controller: 'cultural_heritage_objects'

      # my collection sub-type pages
      resources :organizations, only: [:index, :create], controller: 'collections/organization_collections'
      resources :media_lists, only: [:index, :create], controller: 'collections/media_lists'
      resources :sequential_section_lists, only: [:index, :create], controller: 'collections/media_lists/sequential_section_lists'

      # my other pages
      get 'cart', action: :index, controller: :media_carts
      get 'downloads', action: :index, controller: :downloads
      get 'requests', action: :index, controller: :requests

      get 'jobs', action: :index, controller: :background_jobs
      get 'fund_codes/(:id)', action: :index, controller: :fund_codes, as: 'fund_codes'
      patch 'fund_codes/:id', action: :update, controller: :fund_codes, as: 'fund_codes_update'

      # faceting routes
      get '/media/facet/:id', to: 'media#facet', as: 'dashboard_media_facet'
      get '/media/:collection_id/facet/:id', to: 'add_media#facet', as: 'dashboard_add_media_facet'
      get '/specimens/facet/:id', to: 'biological_specimens#facet', as: 'dashboard_specimens_facet'
      get '/cultural_heritage_objects/facet/:id', to: 'cultural_heritage_objects#facet', as: 'dashboard_chos_facet'
      get '/sequential_section_lists/facet/:id', to: 'collections/media_lists/sequential_section_lists#facet', as: 'dashboard_sequential_section_lists_facet'
    end

    ### LEGACY MS1 URLS THAT REDIRECT TO CONCERN AND COLLECTION SHOW PAGES ###
    scope do
      get 'Detail/SpecimenDetail/Show/specimen_id/:id', to: 'ms1#biological_specimens'
      get 'Detail/MediaDetail/Show/media_id/:id', to: 'ms1#media_group'
      get 'Detail/MediaDetail/Show/media_file_id/:id', to: 'ms1#media'
      get 'Detail/ProjectDetail/Show/project_id/:id', to: 'ms1#projects'
      get 'index.php/Detail/SpecimenDetail/Show/specimen_id/:id', to: 'ms1#biological_specimens'
      get 'index.php/Detail/MediaDetail/Show/media_id/:id', to: 'ms1#media_group'
      get 'index.php/Detail/MediaDetail/Show/media_file_id/:id', to: 'ms1#media'
      get 'index.php/Detail/ProjectDetail/Show/project_id/:id', to: 'ms1#projects'
    end
  end

  # Grant and remove user role statuses not stored in Hyrax user controller
  scope do
    # Grant/remove contributor status
    post 'users/:id/make_contributor' => 'contributors#make_contributor', as: 'make_contributor'
    post 'users/:id/remove_contributor' => 'contributors#remove_contributor', as: 'remove_contributor'

    # Grant/remove batch_submission_contributor status
    post 'users/:id/make_batch_submission_contributor' => 'batch_submission_contributors#make_batch_submission_contributor', as: 'make_batch_submission_contributor'
    post 'users/:id/remove_batch_submission_contributor' => 'batch_submission_contributors#remove_batch_submission_contributor', as: 'remove_batch_submission_contributor'

    # Grant/remove remote_file_submitter status
    post 'users/:id/make_remote_file_submitter' => 'remote_file_submitters#make_remote_file_submitter', as: 'make_remote_file_submitter'
    post 'users/:id/remove_remote_file_submitter' => 'remote_file_submitters#remove_remote_file_submitter', as: 'remove_remote_file_submitter'
  end

  # Add users to auto-generated collection groups
  post 'dashboard/collections/:id/update_collection_groups', action: :update_collection_groups, controller: :collection_roles, as: 'update_collection_groups'

  # DOI unavailable tombstone page show
  get '/unavailable/doi', controller: :tombstone, action: :show

  post 'search_idigbio_by_occurrence_id_ajax', to: 'morphosource/i_dig_bio_search#search_idigbio_by_occurrence_id_ajax'

  delete '/media_batch_edits', to: 'morphosource/batch_edits#destroy_collection', as: 'media_batch_edits'

  ### INITIALIZE BLACKLIGHT BEFORE CATALOG ROUTES ###
  mount Blacklight::Engine => '/'
  concern :searchable, Blacklight::Routes::Searchable.new

  ### CATALOG ###
  scope :catalog do
    get 'media', to: 'media_catalog#index', as: 'media_search'
    get 'objects', to: 'objects_catalog#index', as: 'object_search'
    get 'organizations', to: 'organizations_catalog#index', as: 'organization_search'
    get 'teams_projects', to: 'collections_catalog#index', as: 'collection_search'
    get 'lists', to: 'media_lists_catalog#index', as: 'media_list_search'
    get 'all', to: 'all_catalog#index', as: 'all_search'

    # user managed collections
    get 'teams_projects/managed_by/:user', to: 'user_managed_collections_catalog#index', as: 'managed_collections_search'

    # send to all_catalog controller in order to restrict access to admins only
    resource :catalog, only: [:index], as: 'catalog', path: '/', controller: 'all_catalog' do
      concerns :searchable
    end
  end

  ### CATALOG FACETS SHOW MORE ###
  scope do
    get 'media_catalog/facet/:id', to: 'media_catalog#facet'
    get 'objects_catalog/facet/:id', to: 'objects_catalog#facet'
    get 'organizations_catalog/facet/:id', to: 'organizations_catalog#facet'
    get 'collections_catalog/facet/:id', to: 'collections_catalog#facet'
    get 'lists_catalog/facet/:id', to: 'media_lists_catalog#facet'
    get 'all_catalog/facet/:id', to: 'all_catalog#facet'
  end

  ### REST API (MUST PROCEED CATALOG ROUTES) ###
  scope path: :api, as: 'api' do
    # Media
    get 'media', to: 'media_catalog#index', as: 'media_search', defaults: { format: 'json' }
    get 'media/:id', to: 'media_catalog#show', as: 'media_show', defaults: { format: 'json' }
    get 'media/:id/file-metadata', to: 'media_catalog#show_file_metadata', as: 'media_show_file_metadata', defaults: { format: 'json' }
    get 'media/:id/iiif/manifest', to: 'morphosource/manifests#get_manifest_link', as: 'media_get_manifest_link', defaults: { format: 'json' }

    # Generate media download link for API
    post 'download/:id', to: 'morphosource/media_api_downloads#api_generate_download', as: 'media_generate_download', defaults: { format: 'json' }

    # Physical Objects
    get 'physical-objects', to: 'objects_catalog#index', as: 'physical_objects_search', defaults: { format: 'json' }
    get 'physical-objects/:id', to: 'objects_catalog#show', as: 'physical_object_show', defaults: { format: 'json' }

    # Organizations
    get 'organizations', to: 'organizations_catalog#index', as: 'organizations_search', defaults: { format: 'json' }
    get 'organizations/:id', to: 'organizations_catalog#show', as: 'organizations_show', defaults: { format: 'json' }

    # Teams/Projects
    get 'projects', to: 'collections_catalog#index', as: 'projects_search', defaults: { format: 'json' }
    get 'projects/:id', to: 'collections_catalog#show', as: 'projects_show', defaults: { format: 'json' }

    # Team/Projects Media Related Exports
    get 'projects/:id/media', to: 'morphosource/collections#media_export', as: 'projects_media', defaults: { format: 'json' }
    get 'projects/:id/media-download-counts', to: 'morphosource/collections#media_download_counts', as: 'projects_media_download_counts', defaults: { format: 'json' }
    get 'projects/:id/media-downloads', to: 'morphosource/collections#media_downloads', as: 'projects_media_downloads', defaults: { format: 'json' }
    get 'projects/:id/media-requests', to: 'morphosource/collections#media_requests', as: 'projects_media_requests', defaults: { format: 'json' }

    # Team/Projects Object Exports
    get 'projects/:id/biological-specimens', to: 'morphosource/collections/biological_specimens#objects_export', as: 'projects_specimens', defaults: { format: 'json' }
    get 'projects/:id/cultural-heritage-objects', to: 'morphosource/collections/cultural_heritage_objects#objects_export', as: 'api_projects_chos', defaults: { format: 'json' }

    # Team Projects with Media Not Owned by Team Export
    get 'projects/:id/view-only-media-projects', to: 'morphosource/collections/teams#media_projects', as: 'teams_media_projects', defaults: { format: 'json' }
  end

  # Routes for fund code charge API
  get 'fund_code_charges', to: 'fund_code_charges#index', as: 'fund_code_charges'
  get 'fund_code_charges.csv', to: 'fund_code_charges#index', as: 'fund_code_charges_csv', defaults: { format: 'csv' }
  get 'fund_code_charges.json', to: 'fund_code_charges#index', as: 'fund_code_charges_json', defaults: { format: 'json' }

  ### WEB SUBMISSION ###
  resources :submissions, only: [ :new, :create, :search_bso_ajax,
    :search_taxonomy_ajax, :validate_remote_file_ajax, :organization_for_recordset, :organization_default_media_fields,
    :new_taxonomy_submit, :new_processing_event_submit] do
    collection do
      # AJAX in-submission-flow methods
      post 'validate_remote_file_ajax'
      post 'search_po_ajax'
      post 'save_data'
      get 'search_taxonomy_ajax'
      get 'organization_for_recordset'
      get 'organization_default_media_fields'
      # AJAX physical object or media edit page submission methods
      post 'new_organization_submit'
      post 'new_taxonomy_submit'
      post 'new_processing_event_submit'
    end
  end

  get '/submissions', to: 'submissions#new'

  ### BATCH SUBMISSION ###
  resources :batch_submissions, only: [ :index, :new, :submit, :result ]

  post '/batch_submissions', to: 'batch_submissions#submit'
  post '/batch_submissions/ingest', to: 'batch_submissions#ingest'
  get '/batch_submissions/result', to: 'batch_submissions#result', as: 'batch_submissions_result'

  ### DATA MANAGER SEARCH ###
  get '/data-managers', to: 'morphosource/data_managers#index', as: 'data_managers', constraints: { format: 'json' }

  ### DOCS ###
  resources :docs do
    collection do
      get 'about'
      get 'mission'
      get 'survey'
    end
  end

  # override Hyrax::PagesController
  get '/contributor_terms', to: 'docs#contributor_terms', as: 'contributor_terms'
  get '/terms', to: 'docs#terms', as: 'terms'

  ### STATIC REDIRECTS ###

  # MS1 About/ redirects
  scope path: 'About', as: 'About' do
    get 'home', to: redirect('/docs/about', status: 301)
    get 'contact', to: redirect('/docs/about', status: 301)
    get 'userInfo', to: redirect('/', status: 301)
    get 'userGuide', to: redirect('/', status: 301)
    get 'contributorInfo', to: redirect('/', status: 301)
    get 'terms', to: redirect('/docs/about', status: 301)
    get 'howToCite', to: redirect('/', status: 301)
    get 'API', to: redirect('/', status: 301)
    get 'report', to: redirect('/', status: 301)
    get 'termsAndConditions', to: redirect('/terms', status: 301)
    get 'launch', to: redirect('/', status: 301)
  end

  # Other MS1 redirects
  get '/Stats/dashboard', to: redirect('/', status: 301)
  get '/LoginReg/form', to: redirect('/users/sign_in', status: 301)
  get '/LoginReg/logout', to: redirect('/users/sign_out', status: 301)
  get '/MyProjects/Dashboard/projectList', to: redirect('/dashboard', status: 301)
  get '/Browse/Index', to: redirect('/browse/categories', status: 301)
  get '/Search/Index', to: redirect('/catalog/media', status: 301)

  # Universal Viewer Static Redirect
  get '/uv.html', to: redirect('/uv/uv.html', status: 301)

  ### EXTERNAL FRAMEWORKS AND LIBRARIES ###

  # Resque
  require "resque_web"
  mount ResqueWeb::Engine => "/queues"

  # RIIIF
  mount Riiif::Engine => 'images', as: :riiif if Hyrax.config.iiif_image_server?

  ### HYRAX AND HYDRA RELATED ###

  # Devise and user roles
  devise_for :users, :controllers => { registrations: 'registrations', sessions: 'sessions' }
  mount Hydra::RoleManagement::Engine => '/'

  # ms1 users changing their password must agree to terms and conditions
  devise_scope :user do
    get '/users/password/ms1_edit', to: 'morphosource/passwords#ms1_edit', as: 'ms1_edit_user_password'
  end

  # Questioning authority and Getty TGN support
  mount Qa::Engine => '/authorities'
  get 'authorities/search/:vocab/:subauthority', to: 'morphosource/qa/terms#search'
  get 'authorities/search/:vocab/:subauthority/:facet', to: 'morphosource/qa/terms#search'

  # BrowseEverything
  mount BrowseEverything::Engine => '/browse' # this is needed after updating Hyrax to 2.7

  # Base Hyrax
  mount Hyrax::Engine, at: '/'
  resources :welcome, only: 'index'
  root 'hyrax/homepage#index'

  # Permissions routes to ensure files attached to work have same visibility as work
  namespace :hyrax, path: :concern do
    resources :permissions, only: [] do
      member do
        get :copy_access
        get :copy
      end
    end
  end

  curation_concerns_basic_routes
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end
end
