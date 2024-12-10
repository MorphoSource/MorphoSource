require 'hyrax/role_registry'

module Hyrax
  ##
  # Handles configuration for the Hyrax engine. (NOTE: copied from Hyrax 3.6.0 configuration.rb)
  #
  # This class provides a series of accessors for setting and retrieving global
  # engine options. For convenient reference, options are grouped into the
  # following functional areas:
  #
  # - Groups
  # - Identifiers
  # - IIIF
  # - Local Storage
  # - System Dependencies
  # - Theme
  # - Valkyrie
  #
  # == Groups
  #
  # Hyrax has special handling for three groups: "admin", "registered", and "public".
  #
  # These settings support using custom names for these functional groups in
  # object ACLs.
  #
  # == Identifiers
  # == IIIF
  #
  # Objects in Hyrax serve out IIIF manifests. These configuration options
  # toggle server availability, allow customization of image and info URL
  # generation, and provide other hooks for custom IIIF behavior.
  #
  # == Local Storage
  #
  # Hyrax applications need local disk access to store working copies of files
  # for a variety of purposes. Some of these storage paths need to be available
  # all application processes. These options control the paths to use for each
  # type of file.
  #
  # == System Dependiencies
  #
  # @example adding configuration with `Hyrax.config` (recommended usage)
  #
  #   Hyrax.config do |config|
  #     config.work_requires_files = true
  #     config.derivatives_path('tmp/dir/for/derivatives/')
  #   end
  #
  # == Theme
  #
  # Options related to the overall appearance of Hyrax.
  #
  # == Valkyrie
  #
  # *Experimental:* Options for toggling Hyrax's experimental "Wings" valkyrie
  # adapter and configuring valkyrie.
  #
  # @see Hyrax.config
  class Configuration
    include Callbacks

    def initialize
      @registered_concerns = []
      @role_registry = Hyrax::RoleRegistry.new
      @default_active_workflow_name = DEFAULT_ACTIVE_WORKFLOW_NAME
    end

    DEFAULT_ACTIVE_WORKFLOW_NAME = 'default'.freeze
    private_constant :DEFAULT_ACTIVE_WORKFLOW_NAME

    # Set the default logger for Hyrax.
    attr_writer :logger

    ##
    # @return [Logger]
    def logger
      @logger ||= if defined?(Rails)
                    Rails.logger
                  else
                    Valkyrie.logger
                  end
    end

    # @api public
    # When an admin set is created, we need to activate a workflow.
    # The :default_active_workflow_name is the name of the workflow we will activate.
    #
    # @return [String]
    # @see Sipity::Workflow
    # @see AdminSet
    # @note The active workflow for an admin set can be changed at a later point.
    # @note Changing this value after other AdminSet(s) are created does not alter the already created AdminSet(s)
    attr_accessor :default_active_workflow_name

    # @return [Hyrax::RoleRegistry]
    attr_reader :role_registry
    private :role_registry
    delegate :registered_role?, :persist_registered_roles!, to: :role_registry

    # @api public
    #
    # Exposes a means to register application critical roles
    #
    # @example
    #   Hyrax.config.register_roles do |registry|
    #     registry.add(name: 'captaining', description: 'Grants captain duties')
    #   end
    #
    # @yield [Hyrax::RoleRegistry]
    # @return [TrueClass]
    def register_roles
      yield(@role_registry)
      true
    end

    # @!group Analytics

    attr_writer :analytics
    attr_reader :analytics
    def analytics?
      @analytics ||= false
    end

    # Currently supports 'google' or 'matomo'
    # google is default for backward compatability
    attr_writer :analytics_provider
    def analytics_provider
      @analytics_provider ||=
        ENV.fetch('HYRAX_ANALYTICS_PROVIDER', 'google')
    end

    attr_writer :google_analytics_id
    def google_analytics_id
      @google_analytics_id ||= nil
    end
    alias google_analytics_id? google_analytics_id

    # Defaulting analytic start date to whenever the file was uploaded by leaving it blank
    attr_writer :analytic_start_date
    attr_reader :analytic_start_date

    # @!endgroup
    # @!group Groups

    # Hyrax 3.x config has some of these, we do not use them (so far)

    # @!endgroup
    # @!group Identifier Minting

    attr_writer :enable_noids
    def enable_noids?
      return @enable_noids unless @enable_noids.nil?
      @enable_noids = true
    end

    attr_writer :noid_template
    def noid_template
      @noid_template ||= '.reeddeeddk'
    end

    attr_writer :noid_minter_class
    def noid_minter_class
      @noid_minter_class ||= ::Noid::Rails::Minter::Db
    end

    attr_writer :minter_statefile
    def minter_statefile
      @minter_statefile ||= '/tmp/minter-state'
    end

    # @!endgroup
    # @!group IIIF

    # Enable IIIF image service. This is required to use the
    # IIIF viewer enabled show page
    #
    # If you have run the hyrax:riiif generator, an embedded riiif service
    # will be used to deliver images via IIIF. If you have not, you will
    # need to configure the following other configuration values to work
    # with your image server.
    #
    # @see config.iiif_image_url_builder
    # @see config.iiif_info_url_builder
    # @see config.iiif_image_compliance_level_uri
    # @see config.iiif_image_size_default
    #
    # @note Default is false
    #
    # @return [Boolean] true to enable, false to disable
    def iiif_image_server?
      return @iiif_image_server unless @iiif_image_server.nil?
      @iiif_image_server = false
    end
    attr_writer :iiif_image_server

    # URL that resolves to an image provided by a IIIF image server
    #
    # @return [#call] lambda/proc that generates a URL to an image
    def iiif_image_url_builder
      @iiif_image_url_builder ||= ->(file_id, base_url, _size, _format) { "#{base_url}/downloads/#{file_id.split('/').first}" }
    end

    attr_writer :iiif_image_url_builder

    # URL that resolves to an info.json file provided by a IIIF image server
    #
    # @return [#call] lambda/proc that generates a URL to image info
    def iiif_info_url_builder
      @iiif_info_url_builder ||= ->(_file_id, _base_url) { '' }
    end
    attr_writer :iiif_info_url_builder

    # URL that indicates your IIIF image server compliance level
    #
    # @return [String] valid IIIF image compliance level URI
    def iiif_image_compliance_level_uri
      @iiif_image_compliance_level_uri ||= 'http://iiif.io/api/image/2/level2.json'
    end
    attr_writer :iiif_image_compliance_level_uri

    # IIIF image size default
    #
    # @return [#String] valid IIIF image size parameter
    def iiif_image_size_default
      @iiif_image_size_default ||= '600,'
    end
    attr_writer :iiif_image_size_default

    # IIIF metadata - fields to display in the metadata section
    #
    # @return [#Array] fields
    def iiif_metadata_fields
      @iiif_metadata_fields ||= Hyrax::Forms::WorkForm.required_fields
    end
    attr_writer :iiif_metadata_fields

    # Set predicate for rendering to dc:hasFormat as defined in
    #   IIIF Presentation API context:  http://iiif.io/api/presentation/2/context.json
    attr_writer :rendering_predicate
    def rendering_predicate
      @rendering_predicate ||= ::RDF::Vocab::DC.hasFormat
    end

    # @!endgroup
    # @!group Local Storage

    # @!attribute [w] bagit_dir
    #   Location where BagIt files are exported
    attr_writer :bagit_dir
    def bagit_dir
      @bagit_dir ||= "tmp/descriptions"
    end

    # Path on the local file system where derivatives will be stored
    attr_writer :derivatives_path
    def derivatives_path
      @derivatives_path ||= Rails.root.join('tmp', 'derivatives')
    end

    attr_writer :derivatives_tmp_path
    def derivatives_tmp_path
      @derivatives_tmp_path ||= Rails.root.join("tmp")
    end

    # Path on the local file system where attachments will be stored
    attr_writer :attachments_path
    def attachments_path
      @attachments_path ||= Rails.root.join('tmp', 'attachments')
    end

    # Path on the local file system where originals will be staged before being ingested into Fedora.
    attr_writer :working_path
    def working_path
      @working_path ||= Rails.root.join('tmp', 'uploads')
    end

    # NOTE: This used to be called `working_path` in CurationConcerns
    attr_writer :upload_path
    def upload_path
      @upload_path ||= ->() { Rails.root + 'tmp' + 'uploads' }
    end

    attr_writer :cache_path
    def cache_path
      @cache_path ||= ->() { Rails.root + 'tmp' + 'uploads' + 'cache' }
    end

    # Path on the local file system where where logos and banners for specific collections will be stored.
    attr_writer :branding_path
    def branding_path
      @branding_path ||= Rails.root.join('public', 'branding')
    end

    # @!endgroup
    # @!group System Dependencies

    attr_writer :enable_ffmpeg
    def enable_ffmpeg
      return @enable_ffmpeg unless @enable_ffmpeg.nil?
      @enable_ffmpeg = false
    end

    attr_writer :ffmpeg_path
    def ffmpeg_path
      @ffmpeg_path ||= 'ffmpeg'
    end

    attr_writer :fits_path
    def fits_path
      @fits_path ||= 'fits.sh'
    end

    attr_writer :fits_message_length
    def fits_message_length
      @fits_message_length ||= 5
    end

    # @!attribute [w] import_export_jar_file_path
    #   Path to the jar file for the Fedora import/export tool
    attr_writer :import_export_jar_file_path
    def import_export_jar_file_path
      @import_export_jar_file_path ||= "tmp/fcrepo-import-export.jar"
    end

    # @!attribute [w] virus_scanner
    #   @return [Hyrax::VirusScanner] the default system virus scanner
    attr_writer :virus_scanner
    def virus_scanner
      @virus_scanner ||=
        if Hyrax.primary_work_type.respond_to?(:default_system_virus_scanner)
          Hyrax.primary_work_type.default_system_virus_scanner
        else
          Hyrax::VirusScanner
        end
    end

    # MS-specific dependencies

    attr_writer :blender_path
    def blender_path
      @blender_path ||= 'blender'
    end

    attr_writer :fiji_path
    def fiji_path
      @fiji_path ||= 'fiji'
    end

    # Custom executable path for running fiji scripts
    attr_writer :fiji_script_command
    def fiji_script_command
      @fiji_script_command ||= nil
    end

    attr_writer :python_path
    def python_path
      @python_path ||= 'python3'
    end

    # @!endgroup
    # @!group Theme

    # Site-wide branding fields (can customize logo and title for non-MorphoSource instances)

    # DEPRECATED, not used in this application
    attr_writer :banner_image
    def banner_image
      # This image can be used for free and without attribution. See here for source and license: https://github.com/samvera/hyrax/issues/1551#issuecomment-326624909
      @banner_image ||= 'https://user-images.githubusercontent.com/101482/29949206-ffa60d2c-8e67-11e7-988d-4910b8787d56.jpg'
    end

    attr_writer :logo_image
    def logo_image
      # Default image is 80x80 pixels and is located in app/assets/images/, it is displayed at 40x40 and 60x60
      @logo_image ||= nil
    end

    attr_writer :site_title
    def site_title
      # Will fall back to "MorphoSource" where not otherwise provided
      @site_title ||= nil
    end

    attr_writer :default_site_title
    def default_site_title
      @default_site_title ||= 'MorphoSource'
    end

    # Try to display site announcements? Required github_access_token for GH discussions board
    attr_writer :site_announcements
    def site_announcements
      @site_announcements ||= false
    end

    ##
    # @return [Boolean]
    def disable_wings
      return @disable_wings unless @disable_wings.nil?
      ActiveModel::Type::Boolean.new.cast(ENV.fetch('HYRAX_SKIP_WINGS', false))
    end
    attr_writer :disable_wings

    attr_writer :display_media_download_link
    def display_media_download_link?
      return @display_media_download_link unless @display_media_download_link.nil?
      @display_media_download_link = true
    end

    # @!endgroup
    # @!group Valkyrie

    ##
    # @return [Valkyrie::StorageAdapter]
    def branding_storage_adapter
      @branding_storage_adapter ||= Valkyrie::StorageAdapter.find(:branding_disk)
    end

    ##
    # @param [#to_sym] adapter
    def branding_storage_adapter=(adapter)
      @branding_storage_adapter = Valkyrie::StorageAdapter.find(adapter.to_sym)
    end

    ##
    # @return [Valkyrie::StorageAdapter]
    def derivatives_storage_adapter
      @derivatives_storage_adapter ||= Valkyrie::StorageAdapter.find(:derivatives_disk)
    end

    ##
    # @param [#to_sym] adapter
    def derivatives_storage_adapter=(adapter)
      @derivatives_storage_adapter = Valkyrie::StorageAdapter.find(adapter.to_sym)
    end

    ##
    # @return [#save, #save_all, #delete, #wipe!] an indexing adapter
    def index_adapter
      @index_adapter ||= Valkyrie::IndexingAdapter.find(:null_index)
    end

    ##
    # @param [#to_sym] adapter
    def index_adapter=(adapter)
      @index_adapter = Valkyrie::IndexingAdapter.find(adapter.to_sym)
    end

    ##
    # @return [Boolean] whether to use the experimental valkyrie index
    def query_index_from_valkyrie
      @query_index_from_valkyrie ||= false
    end
    attr_writer :query_index_from_valkyrie

    ##
    # @return [Boolean] whether to use experimental valkyrie storage features
    def use_valkyrie?
      return true if disable_wings # always return true if wings is disabled
      ActiveModel::Type::Boolean.new.cast(ENV.fetch('HYRAX_VALKYRIE', false))
    end
    # @!endgroup
    
    attr_writer :feature_config_path
    def feature_config_path
      @feature_config_path ||= Rails.root.join('config', 'features.yml')
    end

    attr_accessor :temp_file_base, :enable_local_ingest

    attr_writer :display_microdata
    def display_microdata?
      return @display_microdata unless @display_microdata.nil?
      @display_microdata = true
    end

    attr_writer :microdata_default_type
    def microdata_default_type
      @microdata_default_type ||= 'http://schema.org/CreativeWork'
    end

    ##
    # @!attribute [rw] file_set_file_service
    #   @return [Class] implementer of {Hyrax::FileSetFileService}
    attr_writer :file_set_file_service
    def file_set_file_service
      @file_set_file_service ||= Hyrax::FileSetFileService
    end

    attr_writer :max_days_between_fixity_checks
    def max_days_between_fixity_checks
      @max_days_between_fixity_checks ||= 7
    end

    # @!group Groups

    ##
    # @!attribute [w] admin_user_group_name
    #   @return [String]
    # @!attribute [w] public_user_group_name
    #   @return [String]
    # @!attribute [w] registered_user_group_name
    #   @return [String]
    attr_writer :admin_user_group_name
    attr_writer :public_user_group_name
    attr_writer :registered_user_group_name

    ##
    # @api public
    # @return [String]
    def admin_user_group_name
      @admin_user_group_name ||= 'admin'
    end

    ##
    # @api public
    # @return [String]
    def public_user_group_name
      @public_user_group_name ||= 'public'
    end

    ##
    # @api public
    # @return [String]
    def registered_user_group_name
      @registered_user_group_name ||= 'registered'
    end

    # @!endgroup

    attr_writer :enable_noids
    def enable_noids?
      return @enable_noids unless @enable_noids.nil?
      @enable_noids = true
    end

    attr_writer :noid_template
    def noid_template
      @noid_template ||= '.reeddeeddk'
    end

    attr_writer :noid_minter_class
    def noid_minter_class
      @noid_minter_class ||= ::Noid::Rails::Minter::Db
    end

    attr_writer :minter_statefile
    def minter_statefile
      @minter_statefile ||= '/tmp/minter-state'
    end

    attr_writer :display_media_download_link
    def display_media_download_link?
      return @display_media_download_link unless @display_media_download_link.nil?
      @display_media_download_link = true
    end

    attr_writer :fits_path
    def fits_path
      @fits_path ||= 'fits.sh'
    end

    attr_writer :blender_path
    def blender_path
      @blender_path ||= 'blender'
    end

    attr_writer :fiji_path
    def fiji_path
      @fiji_path ||= 'fiji'
    end

    # Custom executable path for running fiji scripts
    attr_writer :fiji_script_command
    def fiji_script_command
      @fiji_script_command ||= nil
    end

    attr_writer :python_path
    def python_path
      @python_path ||= 'python3'
    end

    attr_writer :derivatives_tmp_path
    def derivatives_tmp_path
      @derivatives_tmp_path ||= Rails.root.join("tmp")
    end

    # Skip PyMeshLab for characterizing files (certain combinations of OS/Python can't run pymeshlab)
    attr_writer :skip_pymeshlab_characterization
    def skip_pymeshlab_characterization
      @skip_pymeshlab_characterization ||= false
    end

    # Override characterization runner
    attr_accessor :characterization_runner

    ##
    # @!attribute [w] characterization_proxy
    #   Which FileSet file to use for mime type resolution
    #   @ see Hyrax::FileSetTypeService
    attr_writer :characterization_proxy
    def characterization_proxy
      @characterization_proxy ||= :original_file
    end

    # Attributes for the lock manager which ensures a single process/thread is mutating a ore:Aggregation at once.
    # @!attribute [w] lock_retry_count
    #   How many times to retry to acquire the lock before raising UnableToAcquireLockError
    attr_writer :lock_retry_count
    def lock_retry_count
      @lock_retry_count ||= 600 # Up to 2 minutes of trying at intervals up to 200ms
    end

    # @!attribute [w] lock_time_to_live
    #   How long to hold the lock in milliseconds
    attr_writer :lock_time_to_live
    def lock_time_to_live
      @lock_time_to_live ||= 60_000 # milliseconds
    end

    # @!attribute [w] lock_retry_delay
    #   Maximum wait time in milliseconds before retrying. Wait time is a random value between 0 and retry_delay.
    attr_writer :lock_retry_delay
    def lock_retry_delay
      @lock_retry_delay ||= 200 # milliseconds
    end

    # @!attribute [w] ingest_queue_name
    #   ActiveJob queue to handle default Hyrax jobs or jobs that need to be run as soon as possible.
    attr_writer :ingest_queue_name
    def ingest_queue_name
      @ingest_queue_name ||= :default
    end

    # @!attribute [w] heavy_queue_name
    #   ActiveJob queue to handle performance-heavy jobs, like work characterization and derivative generation.
    attr_writer :heavy_queue_name
    def heavy_queue_name
      @heavy_queue_name ||= :heavy
    end

    # @!attribute [w] mass_ingest_queue_name
    #   ActiveJob queue to handle jobs related to mass ingest.
    attr_writer :mass_ingest_queue_name
    def mass_ingest_queue_name
      @mass_ingest_queue_name ||= :mass_ingest
    end

    # @!attribute [w] batch_submission_queue_name
    #   ActiveJob queue to handle jobs related to batch submission ingest.
    attr_writer :batch_submission_queue_name
    def batch_submission_queue_name
      @batch_submission_queue_name ||= :batch_submission_ingest
    end

    # @!attribute [w] update_fast_queue_name
    #   ActiveJob queue to handle background work or collection update jobs that need to be run relatively soon.
    attr_writer :update_fast_queue_name
    def update_fast_queue_name
      @update_fast_queue_name ||= :update_fast
    end

    # @!attribute [w] update_medium_queue_name
    #   ActiveJob queue to handle background work or collection update jobs that can be run with medium priority.
    attr_writer :update_medium_queue_name
    def update_medium_queue_name
      @update_medium_queue_name ||= :update_medium
    end

    # @!attribute [w] update_slow_queue_name
    #   ActiveJob queue to handle background work or collection update jobs that can be run relatively slowly.
    attr_writer :update_slow_queue_name
    def update_slow_queue_name
      @update_slow_queue_name ||= :update_slow
    end

    # @!attribute [w] import_export_jar_file_path
    #   Path to the jar file for the Fedora import/export tool
    attr_writer :import_export_jar_file_path
    def import_export_jar_file_path
      @import_export_jar_file_path ||= "tmp/fcrepo-import-export.jar"
    end

    # @!attribute [w] bagit_dir
    #   Location where BagIt files are exported
    attr_writer :bagit_dir
    def bagit_dir
      @bagit_dir ||= "tmp/descriptions"
    end

    ### Browse Everything

    # @!attribute [w] enable_browse_everything
    # Whether to enable BrowseEverything or not
    attr_writer :enable_browse_everything
    def enable_browse_everything
      @enable_browse_everything ||= false
    end

    # @!attribute [w] enable_browse_everything_file_system
    # Whether to enable BrowseEverything local file system (Globus) provider
    attr_writer :enable_browse_everything_file_system
    def enable_browse_everything_file_system
      @enable_browse_everything_file_system ||= false
    end

    # @!attribute [w] enable_browse_everything_box
    # Whether to enable BrowseEverything Box provider
    attr_writer :enable_browse_everything_box
    def enable_browse_everything_box
      @enable_browse_everything_box ||= false
    end

    # @!attribute [w] enable_browse_everything_dropbox
    # Whether to enable BrowseEverything Dropbox provider
    attr_writer :enable_browse_everything_dropbox
    def enable_browse_everything_dropbox
      @enable_browse_everything_dropbox ||= false
    end

    # @!attribute [w] enable_browse_everything_google_drive
    # Whether to enable BrowseEverything Google Drive provider
    attr_writer :enable_browse_everything_google_drive
    def enable_browse_everything_google_drive
      @enable_browse_everything_google_drive ||= false
    end

    # @!attribute [w] box_client_id
    # Box API client ID credential
    attr_writer :box_client_id
    def box_client_id
      @box_client_id ||= nil
    end

    # @!attribute [w] box_client_secret
    # Box API client secret credential
    attr_writer :box_client_secret
    def box_client_secret
      @box_client_secret ||= nil
    end
    
    # @!attribute [w] dropbox_client_id
    # Dropbox API client ID credential
    attr_writer :dropbox_client_id
    def dropbox_client_id
      @dropbox_client_id ||= nil
    end

    # @!attribute [w] dropbox_client_secret
    # Dropbox API client secret credential
    attr_writer :dropbox_client_secret
    def dropbox_client_secret
      @dropbox_client_secret ||= nil
    end

    # @!attribute [w] dropbox_download_directory
    # Dropbox API client temporary download directory location
    attr_writer :dropbox_download_directory
    def dropbox_download_directory
      @dropbox_download_directory ||= nil
    end

    # @!attribute [w] google_drive_client_id
    # Google Drive API client ID credential
    attr_writer :google_drive_client_id
    def google_drive_client_id
      @google_drive_client_id ||= nil
    end

    # @!attribute [w] google_drive_client_secret
    # Google Drive API client secret credential
    attr_writer :google_drive_client_secret
    def google_drive_client_secret
      @google_drive_client_secret ||= nil
    end

    # @!attribute [w] whitelisted_ingest_dirs
    #   List of directories which can be used for local file system ingestion.
    attr_writer :whitelisted_ingest_dirs
    def whitelisted_ingest_dirs
      @whitelisted_ingest_dirs ||= \
        if defined? BrowseEverything
          Array.wrap(BrowseEverything.config['file_system'].try(:[], :home)).compact
        else
          []
        end
    end

    callback.enable :after_create_concern, :after_create_fileset,
                    :after_update_content, :after_revert_content,
                    :after_update_metadata, :after_import_local_file_success,
                    :after_import_local_file_failure, :after_fixity_check_failure,
                    :after_destroy, :after_import_url_success,
                    :after_import_url_failure

    # Registers the given curation concern model in the configuration
    # @param [Array<Symbol>,Symbol] curation_concern_types
    def register_curation_concern(*curation_concern_types)
      Array.wrap(curation_concern_types).flatten.compact.each do |cc_type|
        @registered_concerns << cc_type unless @registered_concerns.include?(cc_type)
      end
    end

    # The normalization done by this method must occur after the initialization process
    # so it can take advantage of irregular inflections from config/initializers/inflections.rb
    # @return [Array<String>] the class names of the registered curation concerns
    def registered_curation_concern_types
      @registered_concerns.map { |cc_type| normalize_concern_name(cc_type) }
    end

    # @return [Array<Class>] the registered curation concerns
    def curation_concerns
      registered_curation_concern_types.map(&:constantize)
    end

    # A configuration point for changing the behavior of the license service.
    #
    # @!attribute [w] license_service_class
    #   A configuration point for changing the behavior of the license service.
    #
    #   @see Hyrax::LicenseService for implementation details
    attr_writer :license_service_class
    def license_service_class
      @license_service_class ||= Hyrax::LicenseService
    end

    # A configuration point for changing the behavior of the rights statement service.
    #
    # @!attribute [w] rights_statement_service_class
    #   A configuration point for changing the behavior of the rights statement service.
    #
    #   @see Hyrax::RightsStatementService for implementation details
    attr_writer :rights_statement_service_class
    def rights_statement_service_class
      @rights_statement_service_class ||= Hyrax::RightsStatementService
    end

    attr_writer :index_related_works
    def index_related_works
      @index_related_works ||= false
    end

    attr_writer :unknown_ct_scanner
    def unknown_ct_scanner
      @unknown_ct_scanner ||= nil
    end

    attr_writer :null_organization_id
    def null_organization_id
      @null_organization_id ||= nil
    end

    attr_writer :max_for_download_request_details
    def max_for_download_request_details
      @max_for_download_request_details ||= 100
    end

    attr_writer :host_name
    def host_name
      @host_name ||= "morphosource.org"
    end

    attr_writer :sftp_share_root
    def sftp_share_root
      @sftp_share_root ||= "/sftp_share_root_NOT_DEFINED/"
    end

    attr_writer :front_page_media
    def front_page_media
      @front_page_media ||= nil
    end

    attr_writer :survey_media
    def survey_media
      @survey_media ||= nil
    end

    attr_writer :persistent_hostpath
    def persistent_hostpath
      @persistent_hostpath ||= "http://localhost/files/"
    end

    attr_accessor :redis_connection
    attr_writer :redis_namespace
    def redis_namespace
      @redis_namespace ||= ENV.fetch("HYRAX_REDIS_NAMESPACE", "hyrax")
    end

    attr_writer :libreoffice_path
    def libreoffice_path
      @libreoffice_path ||= "soffice"
    end

    attr_writer :browse_everything
    def browse_everything?
      @browse_everything ||= nil
    end

    attr_writer :citations
    def citations?
      @citations ||= false
    end

    attr_writer :max_notifications_for_dashboard
    def max_notifications_for_dashboard
      @max_notifications_for_dashboard ||= 5
    end

    attr_writer :activity_to_show_default_seconds_since_now
    def activity_to_show_default_seconds_since_now
      @activity_to_show_default_seconds_since_now ||= 24 * 60 * 60
    end

    attr_writer :arkivo_api
    def arkivo_api?
      @arkivo_api ||= false
    end

    # rubocop:disable Metrics/LineLength
    attr_writer :realtime_notifications
    def realtime_notifications?
      # Coerce @realtime_notifications to false if server software
      # does not support WebSockets, and warn the user that we are
      # overriding the value in their config unless it's already
      # flipped to false
      if ENV.fetch('SERVER_SOFTWARE', '').match(/Apache.*Phusion_Passenger/).present?
        Rails.logger.warn('Cannot enable realtime notifications atop Passenger + Apache. Coercing `Hyrax.config.realtime_notifications` to `false`. Set this value to `false` in config/initializers/hyrax.rb to stop seeing this warning.') unless @realtime_notifications == false
        @realtime_notifications = false
      end
      return @realtime_notifications unless @realtime_notifications.nil?
      @realtime_notifications = true
    end
    # rubocop:enable Metrics/LineLength

    def geonames_username=(username)
      Qa::Authorities::Geonames.username = username
    end

    def ms_init_usr=(usr)
    end

    def ms_init_pw=(pw)
    end

    def ms_test_usr=(usr)
    end

    def ms_test_pw=(pw)
    end

    attr_writer :active_deposit_agreement_acceptance
    def active_deposit_agreement_acceptance?
      return true if @active_deposit_agreement_acceptance.nil?
      @active_deposit_agreement_acceptance
    end

    attr_writer :admin_set_predicate
    def admin_set_predicate
      @admin_set_predicate ||= ::RDF::Vocab::DC.isPartOf
    end

    attr_writer :work_requires_files
    def work_requires_files?
      return true if @work_requires_files.nil?
      @work_requires_files
    end

    attr_writer :show_work_item_rows
    def show_work_item_rows
      @show_work_item_rows ||= 10 # rows on show view
    end

    attr_writer :select_number_of_days
    def select_number_of_days
      [30, 60, 90, 120, "all"]
    end

    attr_writer :default_show_work_item_rows
    def default_show_work_item_rows
      @default_show_work_item_rows ||= 10 # default rows per page
    end

    attr_writer :default_rows_per_page_range
    def default_rows_per_page_range
      [10, 20, 40, 60, 80, 100] # rows per page that users can choose
    end

    attr_writer :teams_show_work_item_rows
    def teams_show_work_item_rows
      @teams_show_work_item_rows ||= 10 # default rows per page on teams/project show view
    end

    attr_writer :teams_rows_per_page_range
    def teams_rows_per_page_range
      [10, 20, 40, 60, 80, 100] # rows per page that users can choose
    end

    attr_writer :browse_page_item_rows
    def browse_page_item_rows
      @browse_page_item_rows ||= 10 # default rows per page on browse pages
    end

    attr_writer :browse_page_rows_per_page_range
    def browse_page_rows_per_page_range
      [10, 50, 100, 500, 1000, 2000] # rows per page that users can choose
    end

    attr_writer :batch_user_key
    def batch_user_key
      @batch_user_key
    end

    attr_writer :audit_user_key
    def audit_user_key
      @audit_user_key
    end

    attr_writer :collection_type_index_field
    def collection_type_index_field
      @collection_type_index_field ||= 'collection_type_gid_ssim'
    end

    attr_writer :collection_model
    ##
    # @return [#constantize] a string representation of the collection
    #   model
    def collection_model
      @collection_model ||= '::Collection'
    end

    ##
    # @return [Class] the configured collection model class
    def collection_class
      collection_model.safe_constantize
    end

    attr_writer :admin_set_model
    ##
    # @return [#constantize] a string representation of the admin set
    #   model
    def admin_set_model
      @admin_set_model ||= 'AdminSet'
    end

    ##
    # @return [Class] the configured admin set model class
    def admin_set_class
      admin_set_model.constantize
    end

    attr_writer :id_field
    def id_field
      @id_field || index_field_mapper.id_field
    end

    attr_writer :index_field_mapper
    def index_field_mapper
      @index_field_mapper ||= ActiveFedora.index_field_mapper
    end

    # Should a button with "Share my work" show on the front page to users who are not logged in?
    attr_writer :display_share_button_when_not_logged_in
    def display_share_button_when_not_logged_in?
      return true if @display_share_button_when_not_logged_in.nil?
      @display_share_button_when_not_logged_in
    end

    attr_writer :permission_levels
    def permission_levels
      @permission_levels ||= { "View/Download" => "read",
                               "Edit access" => "edit" }
    end

    attr_writer :owner_permission_levels
    def owner_permission_levels
      @owner_permission_levels ||= { "Edit access" => "edit" }
    end

    attr_writer :permission_options
    def permission_options
      @permission_options ||= { "Choose Access" => "none",
                                "View/Download" => "read",
                                "Edit" => "edit" }
    end

    attr_writer :ms_permission_levels
    def ms_permission_levels
      @ms_permission_levels ||= { "View access" => "read",
                               "Download access" => "download",
                               "Edit access" => "edit" }
    end

    attr_writer :ms_permission_options
    def ms_permission_options
      @ms_permission_options ||= { "Choose Access" => "none",
                                "View" => "read",
                                "Download" => "download",
                                "Edit" => "edit" }
    end

    attr_writer :publisher
    def publisher
      @publisher ||= Hyrax::Publisher.instance
    end

    attr_writer :translate_uri_to_id

    def translate_uri_to_id
      @translate_uri_to_id ||= lambda do |uri|
        baseparts = 2 + [(::Noid::Rails.config.template.gsub(/\.[rsz]/, '').length.to_f / 2).ceil, 4].min
        uri.to_s.sub("#{ActiveFedora.fedora.host}#{ActiveFedora.fedora.base_path}", '').split('/', baseparts).last
      end
    end

    attr_writer :translate_id_to_uri
    def translate_id_to_uri
      @translate_id_to_uri ||= lambda do |id|
        "#{ActiveFedora.fedora.host}#{ActiveFedora.fedora.base_path}/#{::Noid::Rails.treeify(id)}"
      end
    end

    attr_writer :contact_email
    def contact_email
      @contact_email ||= "repo-admin@example.org"
    end

    attr_writer :system_report_recipients
    def system_report_recipients
      @system_report_recipients ||= ""
    end

    attr_writer :override_mail_recipient
    def override_mail_recipient
      @override_mail_recipient ||= ""
    end

    attr_writer :subject_prefix
    def subject_prefix
      @subject_prefix ||= "Contact form:"
    end

    attr_writer :extract_full_text
    def extract_full_text?
      return @extract_full_text unless @extract_full_text.nil?
      @extract_full_text = true
    end

    attr_writer :uploader
    def uploader
      @uploader ||= if Rails.env.development?
                      # use sequential uploads in development to avoid database locking problems with sqlite3.
                      default_uploader_config.merge(limitConcurrentUploads: 1, sequentialUploads: true)
                    else
                      default_uploader_config
                    end
    end

    # Miscellaneous MorphoSource fields

    attr_writer :index_related_works
    def index_related_works
      @index_related_works ||= false
    end

    attr_writer :unknown_ct_scanner
    def unknown_ct_scanner
      @unknown_ct_scanner ||= nil
    end

    attr_writer :null_organization_id
    def null_organization_id
      @null_organization_id ||= nil
    end

    attr_writer :max_for_download_request_details
    def max_for_download_request_details
      @max_for_download_request_details ||= 100
    end

    attr_writer :host_name
    def host_name
      @host_name ||= "morphosource.org"
    end

    attr_writer :sftp_share_root
    def sftp_share_root
      @sftp_share_root ||= "/sftp_share_root_NOT_DEFINED/"
    end

    attr_writer :front_page_media
    def front_page_media
      @front_page_media ||= nil
    end

    ### YAML file application configuration ###

    # community

    attr_writer :community_yml_path
    def community_yml_path
      @community_yml_path ||= "config/links/community.yml"
    end

    def community
      return {} unless ( community_yml_path && File.exist?(community_yml_path) )
      YAML.load_file(community_yml_path) || {}
    end

    attr_reader :header_community
    def header_community
      @header_community ||= community.select { |doc| doc["header"] }
    end

    attr_reader :footer_community
    def footer_community
      @footer_community ||= community.select { |doc| doc["footer"] }
    end

    # docs

    attr_reader :user_profile_metadata_fields
    def user_profile_metadata_fields
      YAML.load_file(Rails.root.join('config', 'models', 'user_metadata.yml'))['user_metadata']
    end

    attr_reader :user_profile_metadata_settings
    def user_profile_metadata_settings
      YAML.load_file(Rails.root.join('config', 'models', 'user_metadata_settings.yml'))['settings']
    end

    attr_reader :user_profile_type_config
    def user_profile_type_config
      YAML.load_file(Rails.root.join('config', 'models', 'user_profile_types.yml'))['profile_types']
    end

    attr_reader :user_demographics
    def user_demographics
      YAML.load_file(Rails.root.join('config', 'models', 'user_demographics.yml'))['ordered_values']
    end

    attr_writer :docs_yml_path
    def docs_yml_path
      @docs_yml_path ||= "config/links/docs.yml"
    end

    def docs
      return {} unless ( docs_yml_path && File.exist?(docs_yml_path) )
      YAML.load_file(docs_yml_path) || {}
    end

    attr_reader :header_docs
    def header_docs
      @header_docs ||= docs.select { |doc| doc["header"] }
    end

    attr_reader :footer_docs
    def footer_docs
      @footer_docs ||= docs.select { |doc| doc["footer"] }
    end

    # resources

    attr_writer :resources_yml_path
    def resources_yml_path
      @resources_yml_path ||= "config/links/resources.yml"
    end

    def resources
      return {} unless ( resources_yml_path && File.exist?(resources_yml_path) )
      YAML.load_file(resources_yml_path) || {}
    end

    attr_reader :header_resources
    def header_resources
      @header_resources ||= resources.select { |doc| doc["header"] }
    end

    attr_reader :footer_resources
    def footer_resources
      @footer_resources ||= resources.select { |doc| doc["footer"] }
    end

    # Enable IIIF image service. This is required to use the
    # IIIF viewer enabled show page
    #
    # If you have run the hyrax:riiif generator, an embedded riiif service
    # will be used to deliver images via IIIF. If you have not, you will
    # need to configure the following other configuration values to work
    # with your image server.
    #
    # @see config.iiif_image_url_builder
    # @see config.iiif_info_url_builder
    # @see config.iiif_image_compliance_level_uri
    # @see config.iiif_image_size_default
    #
    # @note Default is false
    #
    # @return [Boolean] true to enable, false to disable
    def iiif_image_server?
      return @iiif_image_server unless @iiif_image_server.nil?
      @iiif_image_server = false
    end
    attr_writer :iiif_image_server

    # URL that resolves to an image provided by a IIIF image server
    #
    # @return [#call] lambda/proc that generates a URL to an image
    def iiif_image_url_builder
      @iiif_image_url_builder ||= ->(file_id, base_url, _size) { "#{base_url}/downloads/#{file_id.split('/').first}" }
    end
    attr_writer :iiif_image_url_builder

    # URL that resolves to an info.json file provided by a IIIF image server
    #
    # @return [#call] lambda/proc that generates a URL to image info
    def iiif_info_url_builder
      @iiif_info_url_builder ||= ->(_file_id, _base_url) { '' }
    end
    attr_writer :iiif_info_url_builder

    # URL that indicates your IIIF image server compliance level
    #
    # @return [String] valid IIIF image compliance level URI
    def iiif_image_compliance_level_uri
      @iiif_image_compliance_level_uri ||= 'http://iiif.io/api/image/2/level2.json'
    end
    attr_writer :iiif_image_compliance_level_uri

    # IIIF image size default
    #
    # @return [#String] valid IIIF image size parameter
    def iiif_image_size_default
      @iiif_image_size_default ||= '600,'
    end
    attr_writer :iiif_image_size_default

    # IIIF metadata - fields to display in the metadata section
    #
    # @return [#Array] fields
    def iiif_metadata_fields
      @iiif_metadata_fields ||= Hyrax::Forms::WorkForm.required_fields
    end
    attr_writer :iiif_metadata_fields

    # Should a button with "Share my work" show on the front page to users who are not logged in?
    attr_writer :display_share_button_when_not_logged_in
    def display_share_button_when_not_logged_in?
      return true if @display_share_button_when_not_logged_in.nil?
      @display_share_button_when_not_logged_in
    end

    attr_writer :google_analytics_id
    def google_analytics_id
      @google_analytics_id ||= nil
    end
    alias google_analytics_id? google_analytics_id

    # Defaulting analytic start date to whenever the file was uploaded by leaving it blank
    attr_writer :analytic_start_date
    attr_reader :analytic_start_date

    attr_writer :permission_levels
    def permission_levels
      @permission_levels ||= { "View/Download" => "read",
                               "Edit access" => "edit" }
    end

    attr_writer :owner_permission_levels
    def owner_permission_levels
      @owner_permission_levels ||= { "Edit access" => "edit" }
    end

    attr_writer :permission_options
    def permission_options
      @permission_options ||= { "Choose Access" => "none",
                                "View/Download" => "read",
                                "Edit" => "edit" }
    end

    attr_writer :ms_permission_levels
    def ms_permission_levels
      @ms_permission_levels ||= { "View access" => "read",
                               "Download access" => "download",
                               "Edit access" => "edit" }
    end

    attr_writer :ms_permission_options
    def ms_permission_options
      @ms_permission_options ||= { "Choose Access" => "none",
                                "View" => "read",
                                "Download" => "download",
                                "Edit" => "edit" }
    end

    attr_writer :translate_uri_to_id

    def translate_uri_to_id
      @translate_uri_to_id ||= lambda do |uri|
        baseparts = 2 + [(::Noid::Rails.config.template.gsub(/\.[rsz]/, '').length.to_f / 2).ceil, 4].min
        uri.to_s.sub("#{ActiveFedora.fedora.host}#{ActiveFedora.fedora.base_path}", '').split('/', baseparts).last
      end
    end

    attr_writer :translate_id_to_uri
    def translate_id_to_uri
      @translate_id_to_uri ||= lambda do |id|
        "#{ActiveFedora.fedora.host}#{ActiveFedora.fedora.base_path}/#{::Noid::Rails.treeify(id)}"
      end
    end

    attr_writer :contact_email
    def contact_email
      @contact_email ||= "repo-admin@example.org"
    end

    attr_writer :system_report_recipients
    def system_report_recipients
      @system_report_recipients ||= ""
    end

    attr_writer :override_mail_recipient
    def override_mail_recipient
      @override_mail_recipient ||= ""
    end

    attr_writer :subject_prefix
    def subject_prefix
      @subject_prefix ||= "Contact form:"
    end

    attr_writer :extract_full_text
    def extract_full_text?
      return @extract_full_text unless @extract_full_text.nil?
      @extract_full_text = true
    end

    attr_writer :uploader
    def uploader
      @uploader ||= if Rails.env.development?
                      # use sequential uploads in development to avoid database locking problems with sqlite3.
                      default_uploader_config.merge(limitConcurrentUploads: 1, sequentialUploads: true)
                    else
                      default_uploader_config
                    end
    end

    # Site-wide branding fields (can customize logo and title for non-MorphoSource instances)

    # DEPRECATED, not used in this application
    attr_writer :banner_image
    def banner_image
      # This image can be used for free and without attribution. See here for source and license: https://github.com/samvera/hyrax/issues/1551#issuecomment-326624909
      @banner_image ||= 'https://user-images.githubusercontent.com/101482/29949206-ffa60d2c-8e67-11e7-988d-4910b8787d56.jpg'
    end

    attr_writer :logo_image
    def logo_image
      # Default image is 80x80 pixels and is located in app/assets/images/, it is displayed at 40x40 and 60x60
      # This image is displayed on blue backgrounds and should contrast appropriately
      @logo_image ||= nil
    end

    attr_writer :logo_image_alternate
    def logo_image_alternate
      # Default image is 80x80 pixels and is located in app/assets/images/, it is displayed at 40x40 and 60x60
      # This image is displayed on white or gray backgrounds and should contrast appropriately
      @logo_image_alternate ||= nil
    end

    attr_writer :site_title
    def site_title
      # Will fall back to "MorphoSource" where not otherwise provided
      @site_title ||= nil
    end

    attr_writer :default_site_title
    def default_site_title
      @default_site_title ||= 'MorphoSource'
    end

    # Try to display site announcements? Required github_access_token for GH discussions board
    attr_writer :site_announcements
    def site_announcements
      @site_announcements ||= false
    end

    # Packrat API fields (if not using Duke Packrat Storage, these fields are unnecessary)
    attr_writer :packrat_api_endpoint_client_id
    def packrat_api_endpoint_client_id
      @packrat_api_endpoint_client_id ||= nil
    end

    attr_writer :packrat_api_service_url
    def packrat_api_service_url
      @packrat_api_service_url ||= nil
    end

    attr_writer :packrat_api_oidc_long_lived_token
    def packrat_api_oidc_long_lived_token
      @packrat_api_oidc_long_lived_token ||= nil
    end

    attr_writer :packrat_api_idms_token_exchange_url
    def packrat_api_idms_token_exchange_url
      @packrat_api_idms_token_exchange_url ||= nil
    end

    attr_writer :packrat_api_endpoint
    def packrat_api_endpoint
      @packrat_api_endpoint ||= nil
    end

    attr_writer :packrat_api_volume_id
    def packrat_api_volume_id
      @packrat_api_volume_id ||= nil
    end

    # Github GraphQL API credentials
    attr_writer :github_access_token
    def github_access_token
      @github_access_token ||= nil
    end

    # Fund code reporting fields (if not using fund code reporting features, these fields are unnecessary)
    attr_writer :subsidizing_fund_code_id
    def subsidizing_fund_code_id
      @subsidizing_fund_code_id ||= nil
    end

    attr_writer :unused_storage_fund_code_id
    def unused_storage_fund_code_id
      @unused_storage_fund_code_id ||= nil
    end

    attr_writer :solr_select_path
    def solr_select_path
      @solr_select_path ||= ActiveFedora.solr_config.fetch(:select_path, 'select')
    end

    attr_writer :solr_default_method
    def solr_default_method
      @solr_default_method ||= :post
    end

    # A configuration point for changing the available range for
    # selecting per page results
    #
    # @!attribute [w] range_for_number_of_results_to_display_per_page
    #   A configuration point for changing the available range for
    #   selecting per page results
    # @note This has no impact on the default page size of the controller.
    attr_writer :range_for_number_of_results_to_display_per_page

    # @return [Array<Integer>]
    def range_for_number_of_results_to_display_per_page
      @range_for_number_of_results_to_display_per_page ||= [10, 20, 50, 100]
    end

    attr_writer :visibility_map
    # A mapping from visibility string values to permissions; the default and
    # reference implementation is provided by {Hyrax::VisibilityMap}.
    #
    # @return [Hyrax::VisibilityMap]
    # @see Hyrax::VisibilityReader
    # @see Hyrax::VisibilityWriter
    def visibility_map
      @visibility_map ||= Hyrax::VisibilityMap.instance
    end

    private

      # @param [Symbol, #to_s] model_name - symbol representing the model
      # @return [String] the class name for the model
      def normalize_concern_name(model_name)
        model_name.to_s.camelize
      end

      # @return [Hash] config options for the uploader
      def default_uploader_config
        {
          limitConcurrentUploads: 6,
          maxNumberOfFiles: 100,
          maxFileSize: 500.megabytes
        }
      end
  end
end