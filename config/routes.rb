Rails.application.routes.draw do

  scope module: :morphosource do
    scope module: :dashboard do
      post 'dashboard/collections/:id', controller: :collection_members, action: :update_members, as: 'update_members'
    end
  end

  # Physical Object show case pages
  # todo: clean up and rewrite the rules
  scope module: :hyrax do
    get 'biological_specimens/:id', to: 'biological_specimens#showcase'
    get 'cultural_heritage_objects/:id', to: 'cultural_heritage_objects#showcase'
    get 'media/:id', to: 'media#showcase'
    # redirect the default BSO/CHO view to showcase view, except for certain action (e.g. new)
    get 'concern/biological_specimens/new', to: 'biological_specimens#new'
    get 'concern/cultural_heritage_objects/new', to: 'cultural_heritage_objects#new'
    get 'concern/biological_specimens/:id', to: 'biological_specimens#showcase'
    get 'concern/cultural_heritage_objects/:id', to: 'cultural_heritage_objects#showcase'
    get 'concern/parent/:parent_id/biological_specimens/:id', to: 'biological_specimens#showcase'
    get 'concern/parent/:parent_id/cultural_heritage_objects/:id', to: 'cultural_heritage_objects#showcase'
    # redirect the default media view to showcase view, except for certain action (e.g. new)
    get 'concern/media/new', to: 'media#new'
    get 'concern/media/zip', to: 'morphosource/zip_media#zip'
    get 'concern/media/:id', to: 'media#showcase', as: :media_showcase
    # in case we need to reference the old edit page. remove this hyraxedit route later
    get 'concern/media/:id/hyraxedit', to: 'media#hyraxedit'
    put 'concern/media/:id/mint_doi', to: 'media#mint_doi', as: :media_mint_doi
    get 'concern/parent/:parent_id/media/:id', to: 'media#showcase'
    # setup temp routes for the default views (for debugging)
    # remove them later if no longer needed
    get 'concern/media/show/:id', to: 'media#show'
    get 'concern/biological_specimens/show/:id', to: 'biological_specimens#show'
    get 'concern/cultural_heritage_objects/show/:id', to: 'cultural_heritage_objects#show'
  end

  scope module: :hyrax do
    resources :teams, controller: 'teams', only: [:show]
    resources :projects, controller: 'teams', only: [:show]
    #get 'teams/:id', to: 'teams#show'
    get 'teams/specimens/:id', to: 'teams#specimens'
    get 'teams/chos/:id', to: 'teams#chos'
    # media pagination
    get 'team_paging/teams/:id', to: redirect { |params, request| "/teams/#{request.params[:id]}?#{request.params.to_query}" }
    get 'team_paging/projects/:id', to: redirect { |params, request| "/teams/#{request.params[:id]}?#{request.params.to_query}" }
    # bso pagination
    get 'team_paging/teams/specimens/:id', to: redirect { |params, request| "/teams/#{request.params[:id]}?#{request.params.to_query}" }
    get 'team_paging/projects/specimens/:id', to: redirect { |params, request| "/teams/#{request.params[:id]}?#{request.params.to_query}" }
    # cho pagination
    get 'team_paging/teams/chos/:id', to: redirect { |params, request| "/teams/#{request.params[:id]}?#{request.params.to_query}" }
    get 'team_paging/projects/chos/:id', to: redirect { |params, request| "/teams/#{request.params[:id]}?#{request.params.to_query}" }

    #get 'projects/:id', to: 'teams#show'
    get 'projects/specimens/:id', to: 'teams#specimens'
    get 'projects/chos/:id', to: 'teams#chos'
    # media pagination
    get 'project_paging/projects/:id', to: redirect { |params, request| "/projects/#{request.params[:id]}?#{request.params.to_query}" }
    get 'project_paging/teams/:id', to: redirect { |params, request| "/projects/#{request.params[:id]}?#{request.params.to_query}" }
    # bso pagination
    get 'project_paging/projects/specimens/:id', to: redirect { |params, request| "/projects/#{request.params[:id]}?#{request.params.to_query}" }
    get 'project_paging/teams/specimens/:id', to: redirect { |params, request| "/projects/#{request.params[:id]}?#{request.params.to_query}" }
    # cho pagination
    get 'project_paging/projects/chos/:id', to: redirect { |params, request| "/projects/#{request.params[:id]}?#{request.params.to_query}" }
    get 'project_paging/teams/chos/:id', to: redirect { |params, request| "/projects/#{request.params[:id]}?#{request.params.to_query}" }

    get 'dashboard/collections/specimens/:id', to: 'dashboard/collections#specimens'
    get 'dashboard/collections/chos/:id', to: 'dashboard/collections#chos'
    # media pagination
    get 'project_paging/dashboard/collections/:id', to: redirect { |params, request| "/dashboard/collections/#{request.params[:id]}?#{request.params.to_query}" }
    get 'team_paging/dashboard/collections/:id', to: redirect { |params, request| "/dashboard/collections/#{request.params[:id]}?#{request.params.to_query}" }
    get 'project_paging/dashboard/collections/:id/edit', to: redirect { |params, request| "/dashboard/collections/#{request.params[:id]}?#{request.params.to_query}" }
    get 'team_paging/dashboard/collections/:id/edit', to: redirect { |params, request| "/dashboard/collections/#{request.params[:id]}?#{request.params.to_query}" }
    # bso pagination
    get 'project_paging/dashboard/collections/specimens/:id', to: redirect { |params, request| "/dashboard/collections/#{request.params[:id]}?#{request.params.to_query}&tab=biological_specimens" }
    get 'team_paging/dashboard/collections/specimens/:id', to: redirect { |params, request| "/dashboard/collections/#{request.params[:id]}?#{request.params.to_query}&tab=biological_specimens" }
    # cho pagination
    get 'project_paging/dashboard/collections/chos/:id', to: redirect { |params, request| "/dashboard/collections/#{request.params[:id]}?#{request.params.to_query}&tab=cultural_heritage_objects" }
    get 'team_paging/dashboard/collections/chos/:id', to: redirect { |params, request| "/dashboard/collections/#{request.params[:id]}?#{request.params.to_query}&tab=cultural_heritage_objects" }
    # dashboard media/object paging
    get 'media_works_paging/dashboard/my/media', to: redirect { |params, request| "/dashboard/my/media/?#{request.params.to_query}&tab=biological_specimens" }
    get 'media_works_paging/dashboard/my/media/specimens', to: redirect { |params, request| "/dashboard/my/media/?#{request.params.to_query}&tab=biological_specimens" }
    get 'media_works_paging/dashboard/my/media/chos', to: redirect { |params, request| "/dashboard/my/media/?#{request.params.to_query}&tab=cultural_heritage_objects" }
    # my teams/projects paging
    get 'my_projects_paging/dashboard/my/teams', to: redirect { |params, request| "/dashboard/my/projects/?#{request.params.to_query}" }
    get 'my_teams_paging/dashboard/my/teams', to: redirect { |params, request| "/dashboard/my/teams/?#{request.params.to_query}" }
    # browse teams/projects paging
    get 'browse_projects_paging/browse/teams', to: redirect { |params, request| "/browse/projects/?#{request.params.to_query}" }
    get 'browse_teams_paging/browse/teams', to: redirect { |params, request| "/browse/teams/?#{request.params.to_query}" }

    # Note: the following route might effect pagination links
    namespace :dashboard do
      resources :collections, controller: 'collections'

      get 'collections/:parent_id/under', controller: 'ms_nest_collections', action: 'create_collection_under', as: 'create_subcollection_under'
    end

    #get 'dashboard/my/teams', controller: 'my/teams', action: :index
    #get 'dashboard/my/projects', controller: 'my/teams', action: :index

    # Rails.application.routes.url_helpers.my_media_index_path
    scope :dashboard do
      namespace :my do
        resources :teams, only: [:index], controller: 'teams'
        resources :projects, only: [:index], controller: 'teams'
        resources :media, only: [:index], controller: 'media_works'
      end
    end
    #get 'dashboard/my/media', controller: 'my/media_works', action: :index
    get 'dashboard/my/media/specimens', to: 'my/media_works#specimens'
    get 'dashboard/my/media/chos', to: 'my/media_works#chos'

    scope :browse do
      resources :categories, only: [:index], controller: 'browse_categories', as: 'browse_categories'

      resources :teams, only: [:index], controller: 'browse_teams', as: 'browse_teams'
      resources :projects, only: [:index], controller: 'browse_teams', as: 'browse_projects'
      resources :organizations, only: [:index], controller: 'browse_organizations', as: 'browse_organizations'
      resources :media_types_and_modalities, only: [:index], action: :media_types_and_modalities, controller: 'browse', as: 'browse_media_types_and_modalities'
      resources :physical_object_types, only: [:index], action: :physical_object_types, controller: 'browse', as: 'browse_physical_object_types'
      resources :categories, only: [:index], action: :categories, controller: 'browse', as: 'browse_categories'
    end

  end

  # override ProfilesController
  scope module: :morphosource do
    put 'dashboard/profiles/:id', to: 'dashboard/profiles#update'
    patch 'dashboard/profiles/:id', to: 'dashboard/profiles#update'
  end

  require "resque_web"
  mount ResqueWeb::Engine => "/queues"

  mount Riiif::Engine => 'images', as: :riiif if Hyrax.config.iiif_image_server?
  mount Blacklight::Engine => '/'

    concern :searchable, Blacklight::Routes::Searchable.new

  # send to all_catalog controller in order to restrict access to admins only
  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'all_catalog' do
    concerns :searchable
  end

  # ms catalog controllers
  # media
  get 'catalog/media', to: 'media_catalog#index', as: 'media_search'
  get 'media_catalog/facet/:id', to: 'media_catalog#facet'
  # physical objects
  get 'catalog/objects', to: 'objects_catalog#index', as: 'object_search'
  get 'objects_catalog/facet/:id', to: 'objects_catalog#facet'
  # organizations
  get 'catalog/organizations', to: 'organizations_catalog#index', as: 'organization_search'
  get 'organizations_catalog/facet/:id', to: 'organizations_catalog#facet'
  # teams/projects
  get 'catalog/teams_projects', to: 'collections_catalog#index', as: 'collection_search'
  get 'collections_catalog/facet/:id', to: 'collections_catalog#facet'
  # all
  get 'catalog/all', to: 'all_catalog#index', as: 'all_search'
  get 'all_catalog/facet/:id', to: 'all_catalog#facet'

  devise_for :users, :controllers => { registrations: 'registrations', sessions: 'sessions' }
  mount Hydra::RoleManagement::Engine => '/'

  mount Qa::Engine => '/authorities'

  mount BrowseEverything::Engine => '/browse' # this is needed after updating Hyrax to 2.7

  scope module: :morphosource do
    resources :downloads, only: :show
    resources :tags, param: :tag, only: [:index, :show]
    get '/attachments/:id', to: 'attachments#show', as: 'attachment'
  end



  mount Hyrax::Engine, at: '/'
  resources :welcome, only: 'index'
  root 'hyrax/homepage#index'

  scope module: :morphosource do
    get :zip, action: :zip, controller: :zip_media
  end

  namespace :hyrax do
    resources :works, only: [] do
      member do
        resource :custom_thumbnail, only: [:create, :destroy]
      end
    end
  end

  # Permissions routes
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

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :submissions, only: [ :new, :create, :search_bso_ajax,
    :search_taxonomy_ajax, :organization_for_recordset, :organization_default_media_fields,
    :new_organization_submit, :new_taxonomy_submit, :new_device_submit,
    :new_processing_event_submit] do
    collection do
      # AJAX in-submission-flow methods
      post 'search_po_ajax'
      post 'save_data'
      get 'search_taxonomy_ajax'
      get 'organization_for_recordset'
      get 'organization_default_media_fields'
      # AJAX physical object or media edit page submission methods
      post 'new_organization_submit'
      post 'new_taxonomy_submit'
      post 'new_device_submit'
      post 'new_processing_event_submit'
    end
  end

  get '/submissions', to: 'submissions#new'

  resources :docs do
    collection do
      get 'about'
      get 'api'
      get 'citation'
      get 'contributors'
      get 'glossary'
      get 'guide'
      get 'rss'
    end
  end

  scope module: :morphosource do
    scope module: :my do

      # cart items
      post 'add_to_cart', action: :create, controller: :cart_items
      post 'batch_add_to_cart', action: :batch_create, controller: :cart_items
      get 'download_work', action: :download, controller: :cart_items

      # media cart
      get 'dashboard/my/cart', action: :index, controller: :media_carts, as: 'my_cart'
      get 'download_items', action: :download, controller: :media_carts, as: 'download_items'
      delete 'remove_from_cart', action: :destroy, controller: :media_carts, as: 'remove_items'

      # downloads
      get 'dashboard/my/downloads', action: :index, controller: :downloads, as: 'my_downloads'
      post 'batch_create_items', action: :batch_create, controller: :downloads

      # requests
      get 'dashboard/my/requests', action: :index, controller: :requests, as: 'my_requests'
      put 'request_item', action: :request_item, controller: :requests, as: 'request_item'
      get 'request_again', action: :request_again, controller: :requests, as: 'request_again'
      put 'cancel_request', action: :cancel_request, controller: :requests, as: 'cancel_request'
      put 'move_to_cart', action: :move_to_cart, controller: :requests
      post 'request_work', action: :request_work, controller: :requests

      # request manager
      get 'dashboard/my/request_manager', action: :index, controller: :request_managers, as: 'request_manager'
      get 'dashboard/my/previous_requests', action: :index, controller: :request_managers, as: 'previous_requests'
      put 'approve_download', action: :approve_download, controller: :request_managers, as: 'approve_download'
      put 'clear_request', action: :clear_request, controller: :request_managers, as: 'clear_request'
      put 'deny_download', action: :deny_download, controller: :request_managers, as: 'deny_download'
      put 'edit_expiration', action: :edit_expiration, controller: :request_managers, as: 'edit_expiration'
    end
  end

  # when creating a collection, use the morphosource collections controller
  scope module: :morphosource do
    scope module: :dashboard do
      resources :collections, only: [:create]
      # resources :collections, only: [:update_members]
    end
  end

  # Add users to auto-generated collection groups
  post 'dashboard/collections/:id/update_collection_groups', action: :update_collection_groups, controller: :collection_roles, as: 'update_collection_groups'

  # Link organization to team
  scope module: :morphosource do
    scope module: :dashboard do
      post 'dashboard/collections/:id/organizations', action: :link_organization, controller: :linked_teams, as: 'dashboard_collection_link_organization'

      post 'dashboard/collections/:id/unlink_organization', action: :unlink_organization, controller: :linked_teams, as: 'dashboard_collection_unlink_organization'

      patch 'dashboard/collections/:id/update_permissions', to: 'linked_teams#update_permissions', as: 'update_default_permissions'
    end
  end

  # MS1 Static Redirects
  get '/About/home', to: redirect('/docs/about', status: 301)
  get '/About/contact', to: redirect('/docs/about', status: 301)
  get '/About/userInfo', to: redirect('/docs/guide', status: 301)
  get '/About/userGuide', to: redirect('/docs/guide', status: 301)
  get '/About/contributorInfo', to: redirect('/docs/contributors', status: 301)
  get '/About/terms', to: redirect('/docs/glossary', status: 301)
  get '/About/howToCite', to: redirect('/docs/citation', status: 301)
  get '/About/API', to: redirect('/docs/api', status: 301)
  get '/About/report', to: redirect('/docs/rss', status: 301)
  get '/About/termsAndConditions', to: redirect('/terms', status: 301)

  # MS1 Core Redirects
  get '/Stats/dashboard', to: redirect('/', status: 301) 
  get '/LoginReg/form', to: redirect('/users/sign_in', status: 301)
  get '/LoginReg/logout', to: redirect('/users/sign_out', status: 301)
  get '/MyProjects/Dashboard/projectList', to: redirect('/dashboard', status: 301)
  get '/Browse/Index', to: redirect('/browse', status: 301)
  get '/Search/Index', to: redirect('/catalog/media', status: 301)
end
