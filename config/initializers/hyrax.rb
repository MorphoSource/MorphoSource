require 'wings' # fix issue with Hyrax::ValkyrieLazyMigration invoking Wings

Hyrax.config do |config|
  # Injected via `rails g hyrax:work Media`
  config.register_curation_concern :media
  # Injected via `rails g hyrax:work Organization`
  config.register_curation_concern :organization
  # Injected via `rails g hyrax:work Device`
  config.register_curation_concern :device
  # Injected via `rails g hyrax:work ProcessingEvent`
  config.register_curation_concern :processing_event
  # Injected via `rails g hyrax:work BiologicalSpecimen`
  config.register_curation_concern :biological_specimen
  # Injected via `rails g hyrax:work CulturalHeritageObject`
  config.register_curation_concern :cultural_heritage_object
  # Injected via `rails g hyrax:work ImagingEvent`
  # TODO: Remove when all ImagingEvents have been migrated to ImagingEventResource
  config.register_curation_concern :imaging_event
  # Injected via `rails g hyrax:work Taxonomy`
  config.register_curation_concern :taxonomy
  # Injected via `rails g hyrax:work_resource TaxonomyResource`
  config.register_curation_concern :taxonomy_resource
  # Injected via `rails g hyrax:work_resource DeviceResource`
  config.register_curation_concern :device_resource
  # Injected via `rails g hyrax:work_resource ImagingEventResource`
  config.register_curation_concern :imaging_event_resource

  # Register roles that are expected by your implementation.
  # @see Hyrax::RoleRegistry for additional details.
  # @note there are magical roles as defined in Hyrax::RoleRegistry::MAGIC_ROLES
  # config.register_roles do |registry|
  #   registry.add(name: 'captaining', description: 'For those that really like the front lines')
  # end

  # When an admin set is created, we need to activate a workflow.
  # The :default_active_workflow_name is the name of the workflow we will activate.
  # @see Hyrax::Configuration for additional details and defaults.
  # config.default_active_workflow_name = 'default'

  # Which RDF term should be used to relate objects to an admin set?
  # If this is a new repository, you may want to set a custom predicate term here to
  # avoid clashes if you plan to use the default (dct:isPartOf) for other relations.
  # config.admin_set_predicate = ::RDF::DC.isPartOf

  # Which RDF term should be used to relate objects to a rendering?
  # If this is a new repository, you may want to set a custom predicate term here to
  # avoid clashes if you plan to use the default (dct:hasFormat) for other relations.
  # config.rendering_predicate = ::RDF::DC.hasFormat

  ### Site appearance and branding (can be customized for repository instances) ###
  # These should be customized via environment variables

  # Site URL
  config.host_name = ENV['HOST_NAME'] || 'www.morphosource.org'

  # Headers for outbound remote file requests (e.g., IIIF downloads, URL imports for remote-back media)
  config.remote_request_headers = { "User-Agent" => "MorphoSource/5" }

  # Title for UI header and front page tab title
  config.site_title = ENV['SITE_TITLE'].presence || 'MorphoSource'

  # Logo displayed in UI header
  # This image should be placed in app/assets/images/ or in public/.
  # If image is in public/, it should be listed with a slash before the filename ("/image.png").
  # If image is in app/assets/images, no slash is needed ("image.png"), but assets will need to be pre-compiled.
  # Logo image is commonly displayed on blue backgrounds and should contrast appropriately
  config.logo_image = ENV['LOGO_IMAGE'].presence || 'skeleton_head_default_80px.png'

  # Alternate logo displayed in dashboard welcome messahe
  # Similar rules to placement and specification as for config.logo_image
  # Logo image alternate is displayed on white background and should contrast appropriately
  config.logo_image_alternate = ENV['LOGO_IMAGE_ALTERNATE'].presence || 'skeleton_head_blue_80px.png'

  # ID of a media work to be used as the front page preview
  config.front_page_media = Rails.env.production? ? '000009951' : nil

  # ID of a media work to be used as the end survey preview
  config.survey_media = Rails.env.production? ? '000474136' : nil

  # Display site announcements? Requires github_access_token credential for GH discussions board
  config.site_announcements = ENV['GITHUB_ACCESS_TOKEN'].present?

  ### Initial users and system users (should be customized for repository instances) ###

  # Initial user accounts that will be created when running rake task create_development_users

  # Single user email set by ENV["MS_TEST_USR"]
  config.ms_test_usr = Morphosource.ms_test_usr
  # Set by ENV["MS_TEST_PW"]
  config.ms_test_pw = Morphosource.ms_test_pw

  # Initial user accounts that will be created when running rake task create_development_users

  # One or more user emails set by ENV["MS_INIT_USR"], comma separated (user@email1.com,user2@email2.com)
  config.ms_init_usr = Morphosource.ms_init_usr
  # Set by ENV["MS_INIT_PW"]
  config.ms_init_pw = Morphosource.ms_init_pw

  # Email message sender (for download review notifications, contributor app responses, etc.)
  # Rake task create_production_users will create a user account corresponding to this email
  config.contact_email = ENV['CONTACT_EMAIL'] || "do.not.reply@morphosource.org"

  # Email address(es) for receiving system reports (e.g duplicate specimens)
  config.system_report_recipients = ENV['SYSTEM_REPORT_RECIPIENTS'] || ""

  # Email address for overriding all mail recipients when sending emails from actionmailer
  # (for receiving emails in dev / local test environments)
  config.override_mail_recipient = ENV['OVERRIDE_MAIL_RECIPIENT'] || ""

  # The user who runs some jobs and other process not attributed to a specific user, such as default admin set creation.
  # Should be user key of site-wide admin user or dedicated system job user
  config.system_user_key = ENV['SYSTEM_USER_KEY'] || '614de0'

  # The user who runs batch jobs.
  # Should be user key of site-wide admin user or dedicated batch job user
  config.batch_user_key = ENV['BATCH_USER_KEY'] || '614de0'

  # The user who runs fixity check jobs. Update this if you aren't using emails
  # Should be user key of site-wide admin user or dedicated audit job user
  # By default, this is user key of morphosource@duke.edu site-wide admin user
  config.audit_user_key = ENV['AUDIT_USER_KEY'] || '614de0'

  # Location autocomplete uses geonames to search for named regions
  # Username for connecting to geonames. Is set by ENV["GEONAMES_USER"]
  config.geonames_username = Morphosource.geonames_user

  ### Media contribution settings (should be customized for repository instances) ###

  # Imaging devices not associated with any specific organization are instead grouped under a "null" organization
  # This should be the ID of a specially created null organization
  config.null_organization_id = ENV['NULL_ORGANIZATION_ID'] || ( Rails.env.production? ? '000710951' : nil )

  # Device work ID for "unknown CT scanner"
  config.unknown_ct_scanner = ENV['UNKNOWN_CT_SCANNER'] || ( Rails.env.production? ? '00000D567' : nil )

  ### Analytics and external API connections (can be customized for repository instances) ###

  # Enable recording/displaying usage statistics in the UI
  # Defaults to false
  # Requires a Google Analytics id and OAuth2 keyfile.  See README for more info
  # config.analytics = false
  config.analytics = ENV['TRACK_GOOGLE_ANALYTICS'] == 'true'

  # Analytics provider, Hyrax supports ga4, google (ga3, defunct) and matomo
  config.analytics_provider = ENV.fetch('HYRAX_ANALYTICS_PROVIDER', 'ga4')

  # Google Analytics GA4 Measurement ID
  config.google_analytics_id = ENV['GOOGLE_ANALYTICS_ID']

  # Date you wish to start collecting Google Analytic statistics for
  # Leaving it blank will set the start date to when ever the file was uploaded by
  # NOTE: if you have always sent analytics to GA for downloads and page views leave this commented out
  # NOTE2: Env variable should be a string in format YYYY-MM-DD, e.g. "2010-09-01" for Sep 1 2010
  # NOTE3: Default value is Jan 1st of 2021, when MorphoSource 2.0 launched
  config.analytic_start_date = ENV['GOOGLE_ANALYTICS_START_DATE'].present? ? DateTime.parse(ENV['GOOGLE_ANALYTICS_START_DATE']) : DateTime.new(2021, 1, 1)

  # Packrat API fields (if not using Duke Packrat Storage, these fields are unnecessary)
  config.packrat_api_endpoint_client_id = ENV.fetch('ENDPOINT_CLIENT_ID', 'packrat-production')
  config.packrat_api_service_url = ENV.fetch('SERVICE_URL', 'https://packrat.oit.duke.edu')
  config.packrat_api_oidc_long_lived_token = ENV.fetch('OIDC_LONG_LIVED_TOKEN', nil)
  config.packrat_api_idms_token_exchange_url = ENV.fetch('IDMS_TOKEN_EXCHANGE_URL', 'https://idms-web-ws.oit.duke.edu/idm-ws/clientSecret/createClientToken')
  config.packrat_api_endpoint = ENV.fetch('PACKRAT_API_ENDPOINT', '/api/v2')
  config.packrat_api_volume_id = ENV.fetch('PACKRAT_API_VOLUME_ID', 1931)

  # Github GraphQL API credentials
  config.github_access_token = ENV.fetch('GITHUB_ACCESS_TOKEN', nil)

  ### Locations where temporary or ancillary files are stored ###

  # Temporary paths to hold uploads before they are ingested into FCrepo
  # These must be lambdas that return a Pathname. Can be configured separately
  config.upload_path = ->() { ENV['HYRAX_UPLOAD_PATH'].present? ? ENV['HYRAX_UPLOAD_PATH'] : Rails.root + 'tmp' + 'uploads' }
  config.cache_path = ->() { ENV['HYRAX_CACHE_PATH'].present? ? ENV['HYRAX_CACHE_PATH'] : Rails.root + 'tmp' + 'uploads' + 'cache' }

  # Location on local file system where uploaded files will be staged
  # prior to being ingested into the repository or having derivatives generated.
  # If you use a multi-server architecture, this MUST be a shared volume.
  # config.working_path = Rails.root.join( 'tmp', 'uploads')
  config.working_path = ENV['HYRAX_WORKING_PATH'].present? ? ENV['HYRAX_WORKING_PATH'] : Rails.root + 'tmp' + 'uploads'

  # Location on local file system where derivatives will be stored
  # If you use a multi-server architecture, this MUST be a shared volume
  config.derivatives_path = ENV.fetch("DERIVATIVES_PATH", Rails.root.join("tmp", "derivatives"))

  # Location on local file system where attachments will be stored
  # If you use a multi-server architecture, this MUST be a shared volume
  config.attachments_path = ENV.fetch("ATTACHMENTS_PATH", Rails.root.join("tmp", "attachments"))

  # Path to where derivative generation tmp files should be placed (temporary method)
  config.derivatives_tmp_path = ENV.fetch("DERIVATIVES_TMP_PATH", Rails.root.join("tmp"))

  # Path on the local file system where Valkyrie-managed files will be stored
  config.valkyrie_disk_storage_path = ENV.fetch("VALKYRIE_DISK_STORAGE_PATH", Rails.root.join("storage", "files"))

  # directory path for finding MS1 dropbox user folders
  config.sftp_share_root = ENV['SFTP_SHARE_ROOT']

  # Where to store tempfiles, leave blank for the system temp directory (e.g. /tmp)
  # config.temp_file_base = '/home/developer1'

  ### Derivative and characterizer tool paths and settings ###

  # If you have ffmpeg installed and want to transcode audio and video set to true
  config.enable_ffmpeg = true

  # Path to the ffmpeg tool
  config.ffmpeg_path = 'ffmpeg'

  # Path to the file characterization tool
  config.fits_path = ENV.fetch("FITS_PATH", "fits.sh")

  # find blender in PATH variable.  If exists, set config.blender_path to it
  # if blender is not in PATH, get the path from BLENDER_PATH variable
  # note that tool_path (e.g. used in blender.rb) is by default set to config.blender_path, but can
  # be overridden by an argument
  blender_in_path = ENV.fetch("PATH").split(':').select{|path| path.include?('blender')}
  if blender_in_path.present?
    config.blender_path = blender_in_path.first
  else
    config.blender_path = ENV.fetch("BLENDER_PATH", nil)
  end

  config.fiji_path = ENV.fetch("FIJI_PATH", "fiji")

  # Custom full executable path for fiji command to run scripts
  config.fiji_script_command = ENV.fetch("FIJI_SCRIPT_COMMAND", nil)

  config.python_path = ENV.fetch("MORPHOSOURCE_PYTHON", "python3")

  # Skip PyMeshLab for characterization
  config.skip_pymeshlab_characterization = ActiveModel::Type::Boolean.new.cast(ENV.fetch("SKIP_PYMESHLAB_CHARACTERIZATION", false))

  # Path to the file derivatives creation tool
  # config.libreoffice_path = "soffice"

  # Option to enable/disable full text extraction from PDFs
  # Default is true, set to false to disable full text extraction
  # config.extract_full_text = true

  ### IIIF ###

  # Enable IIIF image service. This is required to use the
  # UniversalViewer-ified show page
  #
  # If you have run the riiif generator, an embedded riiif service
  # will be used to deliver images via IIIF. If you have not, you will
  # need to configure the following other configuration values to work
  # with your image server:
  #
  #   * iiif_image_url_builder
  #   * iiif_info_url_builder
  #   * iiif_image_compliance_level_uri
  #   * iiif_image_size_default
  #
  # Default is false
  config.iiif_image_server = true

  # Returns a URL that resolves to an image provided by a IIIF image server
  config.iiif_image_url_builder = lambda do |file_id, base_url, size, format|
    Riiif::Engine.routes.url_helpers.image_url(file_id, host: base_url, size: size, format: format)
  end
  # config.iiif_image_url_builder = lambda do |file_id, base_url, size|
  #   "#{base_url}/downloads/#{file_id.split('/').first}"
  # end

  # Returns a URL that resolves to an info.json file provided by a IIIF image server
  config.iiif_info_url_builder = lambda do |file_id, base_url|
    uri = Riiif::Engine.routes.url_helpers.info_url(file_id, host: base_url)
    uri.sub(%r{/info\.json\Z}, '')
  end
  # config.iiif_info_url_builder = lambda do |_, _|
  #   ""
  # end

  # Returns a URL that indicates your IIIF image server compliance level
  # config.iiif_image_compliance_level_uri = 'http://iiif.io/api/image/2/level2.json'

  # Returns a IIIF image size default
  # config.iiif_image_size_default = '600,'

  # Fields to display in the IIIF metadata section; default is the required fields
  config.iiif_metadata_fields = [:title, :part, :physical_object_title, :taxonomies_titles,
    :media_organization, :human_readable_media_type, :human_readable_modality,
    :depositor_name, :rights_holder, :rights_statement, :license, :funding
  ]

  ### General configuration ###

  # Allow use of legacy AF models
  # If using Frayja/Frigg then use the resource they provide
  if Hyrax.config.valkyrie_transition?
    config.collection_model = '::Collection' # todovalk change this to CollectionResource
    config.admin_set_model = 'AdminSetResource'
    config.file_set_model = 'Hyrax::FileSet'
  else
    # allow legacy AF models
    config.collection_model = '::Collection'
    config.admin_set_model = 'AdminSet'
    config.file_set_model = '::FileSet'
  end

  # Options to control the file uploader
  config.uploader = {
    limitConcurrentUploads: 6,
    maxNumberOfFiles: 10000,
    maxFileSize: 50.gigabytes
  }

  # Hyrax uses NOIDs for files and collections instead of Fedora UUIDs
  # where NOID = 10-character string and UUID = 32-character string w/ hyphens
  # config.enable_noids = true

  # Template for your repository's NOID IDs
  config.noid_template = ".zddddddddd"

  # Use the database-backed minter class
  # config.noid_minter_class = Noid::Rails::Minter::Db

  # Store identifier minter's state in a file for later replayability
  # config.minter_statefile = '/tmp/minter-state'

  # Prefix for Redis keys
  # config.redis_namespace = "hyrax"

  # How many seconds back from the current time that we should show by default of the user's activity on the user's dashboard
  # config.activity_to_show_default_seconds_since_now = 24*60*60

  # Hyrax can integrate with Zotero's Arkivo service for automatic deposit
  # of Zotero-managed research items.
  # config.arkivo_api = false

  # Stream realtime notifications to users in the browser
  config.realtime_notifications = true

  # Should the acceptance of the licence agreement be active (checkbox), or
  # implied when the save button is pressed? Set to true for active
  # The default is true.
  # config.active_deposit_agreement_acceptance = true

  # Should work creation require file upload, or can a work be created first
  # and a file added at a later time?
  # The default is true.
  config.work_requires_files = false

  # Should a button with "Share my work" show on the front page to all users (even those not logged in)?
  # config.display_share_button_when_not_logged_in = true

  # Should schema.org microdata be displayed?
  # config.display_microdata = true

  # What default microdata type should be used if a more appropriate
  # type can not be found in the locale file?
  # config.microdata_default_type = 'http://schema.org/CreativeWork'

  # Should the media display partial render a download link?
  config.display_media_download_link = false

  # A configuration point for changing the behavior of the license service
  #   @see Hyrax::LicenseService for implementation details
  # config.license_service_class = Hyrax::LicenseService

  # Labels for display of permission levels
  # config.permission_levels = { "View/Download" => "read", "Edit access" => "edit" }

  # Labels for permission level options used in dropdown menus
  # config.permission_options = { "Choose Access" => "none", "View/Download" => "read", "Edit" => "edit" }

  # Labels for owner permission levels
  # config.owner_permission_levels = { "Edit Access" => "edit" }

  # Max length of FITS messages to display in UI
  # config.fits_message_length = 5

  # ActiveJob queue to handle ingest-like jobs
  # config.ingest_queue_name = :default

  ## Attributes for the lock manager which ensures a single process/thread is mutating a ore:Aggregation at once.
  # How many times to retry to acquire the lock before raising UnableToAcquireLockError
  # config.lock_retry_count = 600 # Up to 2 minutes of trying at intervals up to 200ms
  #
  # Maximum wait time in milliseconds before retrying. Wait time is a random value between 0 and retry_delay.
  # config.lock_retry_delay = 200
  #
  # How long to hold the lock in milliseconds
  # config.lock_time_to_live = 60_000

  ## Do not alter unless you understand how ActiveFedora handles URI/ID translation
  # config.translate_id_to_uri = lambda do |uri|
  #                                baseparts = 2 + [(Noid::Rails::Config.template.gsub(/\.[rsz]/, '').length.to_f / 2).ceil, 4].min
  #                                uri.to_s.sub(baseurl, '').split('/', baseparts).last
  #                              end
  # config.translate_uri_to_id = lambda do |id|
  #                                "#{ActiveFedora.fedora.host}#{ActiveFedora.fedora.base_path}/#{Noid::Rails.treeify(id)}"
  #                              end

  ## Fedora import/export tool
  #
  # Path to the Fedora import export tool jar file
  # config.import_export_jar_file_path = "tmp/fcrepo-import-export.jar"
  #
  # Location where BagIt files should be exported
  # config.bagit_dir = "tmp/descriptions"

  # Enable or disable BrowseEverything cloud file provider upload
  config.enable_browse_everything = ActiveModel::Type::Boolean.new.cast(ENV.fetch('ENABLE_BROWSE_EVERYTHING', false))

  # Enable or disable BrowseEverything local file system (Globus) provider
  config.enable_browse_everything_file_system = ActiveModel::Type::Boolean.new.cast(ENV.fetch('ENABLE_BROWSE_EVERYTHING_FILE_SYSTEM', false))

  # Enable or disable specific BrowseEverything cloud file providers
  config.enable_browse_everything_box = ActiveModel::Type::Boolean.new.cast(ENV.fetch('ENABLE_BROWSE_EVERYTHING_BOX', false))
  config.enable_browse_everything_dropbox = ActiveModel::Type::Boolean.new.cast(ENV.fetch('ENABLE_BROWSE_EVERYTHING_DROPBOX', false))
  config.enable_browse_everything_google_drive = ActiveModel::Type::Boolean.new.cast(ENV.fetch('ENABLE_BROWSE_EVERYTHING_GOOGLE_DRIVE', false))

  # Box API credentials
  config.box_client_id = ENV.fetch('BOX_CLIENT_ID', nil)
  config.box_client_secret = ENV.fetch('BOX_CLIENT_SECRET', nil)

  # Dropbox API credentials and Browse Everything settings
  config.dropbox_client_id = ENV.fetch('DROPBOX_CLIENT_ID', nil)
  config.dropbox_client_secret = ENV.fetch('DROPBOX_CLIENT_SECRET', nil)
  config.dropbox_download_directory = ENV.fetch('DROPBOX_DOWNLOAD_DIRECTORY', 'tmp/')

  # Google Drive API credentials
  config.google_drive_client_id = ENV.fetch('GOOGLE_DRIVE_CLIENT_ID', nil)
  config.google_drive_client_secret = ENV.fetch('GOOGLE_DRIVE_CLIENT_SECRET', nil)


  # If browse-everything has been enabled and configured, load the configs.  Otherwise, set to nil.
  begin
    if config.enable_browse_everything && defined?(BrowseEverything)
      be_config = {}
      if config.enable_browse_everything_box && config.box_client_id && config.box_client_secret
        be_config[:box] = {
          client_id: config.box_client_id,
          client_secret: config.box_client_secret
        }
      end
      if config.enable_browse_everything_dropbox && config.dropbox_client_id && config.dropbox_client_secret
        be_config[:dropbox] = {
          client_id: config.dropbox_client_id,
          client_secret: config.dropbox_client_secret,
          download_directory: config.dropbox_download_directory
        }
      end
      if config.enable_browse_everything_google_drive && config.google_drive_client_id && config.google_drive_client_secret
        be_config[:google_drive] = {
          client_id: config.google_drive_client_id,
          client_secret: config.google_drive_client_secret
        }
      end

      BrowseEverything.config = be_config
      config.browse_everything = BrowseEverything.config
    else
      Rails.logger.warn "BrowseEverything is not enabled or installed"
    end
  rescue Errno::ENOENT
    config.browse_everything = nil
  end

  #config.browse_everything = nil

  ## Whitelist all directories which can be used to ingest from the local file
  # system.
  #
  # Any file, and only those, that is anywhere under one of the specified
  # directories can be used by CreateWithRemoteFilesActor to add local files
  # to works. Files uploaded by the user are handled separately and the
  # temporary directory for those need not be included here.
  #
  # Default value includes BrowseEverything.config['file_system'][:home] if it
  # is set, otherwise default is an empty list. You should only need to change
  # this if you have custom ingestions using CreateWithRemoteFilesActor to
  # ingest files from the file system that are not part of the BrowseEverything
  # mount point.
  #
  config.whitelisted_ingest_dirs = ENV.fetch('WHITELISTED_INGEST_DIRS', '').split(':').presence || ['/nas/morphosource_globus/', '/app/samvera/hyrax-webapp/tmp/', '/app/samvera/hyrax-webapp/spec/fixtures/images/', '/app/samvera/hyrax-webapp/spec/fixtures/bunny/', '/app/samvera/hyrax-webapp/spec/fixtures/dcm_stack/']

  config.index_related_works = true

  # Default storage allocation in gigabytes for new DataAllocations
  config.default_storage_total_gb = 15

  # Fund code reporting fields (if not using fund code reporting features, these fields are unnecessary)
  config.subsidizing_fund_code_id = ENV.fetch('SUBSIDIZING_FUND_CODE_ID', Rails.env.production? ? 4 : nil)
  config.unused_storage_fund_code_id = ENV.fetch('UNUSED_STORAGE_FUND_CODE_ID', Rails.env.production? ? 18 : nil)

  # URL for donation links
  # 'Donate' buttons on the front page and in fundraising modals will link to this URL
  config.donation_url = ENV.fetch('DONATION_URL', "https://www.gifts.duke.edu/?designation=391001239")
end

Date::DATE_FORMATS[:standard] = "%m/%d/%Y"

Qa::Authorities::Local.register_subauthority('subjects', 'Qa::Authorities::Local::TableBasedAuthority')
Qa::Authorities::Local.register_subauthority('languages', 'Qa::Authorities::Local::TableBasedAuthority')
Qa::Authorities::Local.register_subauthority('genres', 'Qa::Authorities::Local::TableBasedAuthority')
