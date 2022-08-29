require 'morphosource'
require 'ms1to2'
require 'importer'

namespace :morphosource do
  desc 'Runs rake task db:schema:load if no tables exist'
  task db_schema_load_if_needed: :environment do
    if !ActiveRecord::Base.connection.data_sources.present?
      Rake::Task['db:schema:load'].invoke
    end
  end

  desc 'Runs db:create, morphosource:db_schema_load_if_needed, db:migrate'
  task db_setup_idempotent: :environment do
    Rake::Task['db:create'].invoke
    Rake::Task['morphosource:db_schema_load_if_needed'].invoke
    Rake::Task['db:migrate'].invoke
  end

  desc 'MorphoSource Setup'
  task :setup  => :environment do
    # default admin set
    Rake::Task["hyrax:default_admin_set:create"].invoke
    # team and project collection types
    Rake::Task['morphosource:create_collection_types'].invoke
    # admin role
    Rake::Task['morphosource:create_admin_role'].invoke
    # batch submission contributor role
    Rake::Task['morphosource:create_batch_submission_contributor_role'].invoke
    # contributor role
    Rake::Task['morphosource:create_contributor_role'].invoke
    # charge api role
    Rake::Task['morphosource:create_charge_api_role'].invoke
  end

  desc 'MorphoSource Docker Setup'
  task :docker_setup => :environment do
    Rails.logger.info('Setup DB')
    Rake::Task['db:create'].invoke
    Rake::Task['morphosource:db_schema_load_if_needed'].invoke
    Rake::Task['db:migrate'].invoke
    Rails.logger.info('Clear cache')
    Rake::Task['tmp:cache:clear'].invoke
    Rails.logger.info('Load workflow')
    Rake::Task['hyrax:workflow:load'].invoke
    Rails.logger.info('Setup MorphoSource app')
    Rake::Task['morphosource:setup'].invoke
    Rails.logger.info('Create initial users')
    Rake::Task['morphosource:create_production_users'].invoke
    Rails.logger.info('Initiate dev caching')
    Rake::Task['morphosource:dev_cache_on'].invoke
  end

  # Runs rake task dev:cache to turn on caching only if it is off
  task dev_cache_on: :environment do
    Rake::Task['dev:cache'].invoke if !Rails.root.join('tmp', 'caching-dev.txt').exist?
  end
  
  # Taken from hyrax:stats:user_stats at https://github.com/samvera/hyrax/blob/v2.9.0/lib/tasks/stats_tasks.rake
  # But using a slightly customized UserStatImporter to prevent DB row bloat
  desc "Cache work view, file view & file download stats for all users"
  task import_user_stats: :environment do
    importer = Morphosource::UserStatImporter.new(verbose: true, logging: true)
    importer.import
  end

  # Loosely adapted from https://github.com/curationexperts/nurax/blob/master/lib/tasks/nurax.rake
  # Hyrax's CharacterizeJob performs file characterization and then queues up CreativeDerivativesJob.
  desc 'Loop over all FileSets, (re-)characterize the files, and (re-)generate derivatives'
  task :characterize_and_generate_derivatives => :environment do
    FileSet.find_each do |fs|
      if fs.original_file.nil?
        Rails.logger.warn("No :original_file relation returned for FileSet (#{fs.id})" )
        next
      end
      wrapper = JobIoWrapper.find_by(file_set_id: fs.id)
      path_hint = wrapper.uploaded_file ? wrapper.uploaded_file.uploader.path : wrapper.path
      Rails.logger.debug("(Re-)characterizing files and (re-)generating derivatives for FileSet #{fs.id} in the background")
      CharacterizeJob.perform_later(fs, fs.original_file.id, path_hint)
    end
  end

  desc 'Re-characterize and generate derivatives for all FileSets without derivatives'
  task :characterize_and_generate_derivatives_if_missing => :environment do
    FileSet.find_each do |fs|
      next if !fs.original_file.presence
      m = fs.parents&.first
      media_type = m&.media_type&.first
      derivatives = Morphosource::DerivativePath.derivatives_for_reference(fs)
      if derivatives.length == 0
        Rails.logger.warn("FileSet ID #{fs.id} (Media work ID #{m&.id.to_s}, media type #{media_type.to_s}) with mime type #{fs.mime_type} has no derivatives, re-characterizing and generating derivatives")
        wrapper = JobIoWrapper.find_by(file_set_id: fs.id)
        path_hint = wrapper.uploaded_file ? wrapper.uploaded_file.uploader.path : wrapper.path
        CharacterizeJob.perform_later(fs, fs.original_file.id, path_hint)
      end
    end
  end

  # Loosely adapted from https://github.com/curationexperts/nurax/blob/master/lib/tasks/nurax.rake
  # Performs CreateDerivativesJob independently of CharacterizeJob.
  desc 'Loop over all FileSets and (re-)generate derivatives'
  task :generate_derivatives => :environment do
    FileSet.find_each do |fs|
      if fs.original_file.nil?
        Rails.logger.warn("No :original_file relation returned for FileSet (#{fs.id})" )
        next
      end
      wrapper = JobIoWrapper.find_by(file_set_id: fs.id)
      path_hint = wrapper.uploaded_file ? wrapper.uploaded_file.uploader.path : wrapper.path
      Rails.logger.debug("(Re-)generating derivatives for FileSet #{fs.id} in the background")
      CreateDerivativesJob.perform_later(fs, fs.original_file.id, path_hint)
    end
  end

  desc "switch logger to stdout"
  task :to_stdout => [:environment] do
    Rails.logger = Logger.new(STDOUT)
  end

  desc 'Loop over all FileSets and determine how many are missing derivatives'
  task :check_derivatives => :environment do
    Rails.logger.info("#{Media.count} Media works deposited, #{FileSet.count} FileSets deposited")

    n = 0
    FileSet.find_each do |fs|
      next if !fs.original_file.presence
      m = fs.parents&.first
      media_type = m&.media_type&.first
      derivatives = Morphosource::DerivativePath.derivatives_for_reference(fs)
      if derivatives.length == 0
        Rails.logger.warn("FileSet ID #{fs.id} (Media work ID #{m&.id.to_s}, media type #{media_type.to_s}) with mime type #{fs.mime_type} has no derivatives")
        n += 1
      end
    end
    Rails.logger.warn("#{n} FileSets lack derivatives")
  end

  desc 'Loop over media and check how many lack FileSets or have FileSets without original_file'
  task :check_file_ingests => :environment do
    Rails.logger.info("#{Media.count} Media works deposited, #{FileSet.count} FileSets deposited")

    n = 0
    Media.find_each do |m|
      media_type = m&.media_type&.first
      if !m.file_sets.presence
        Rails.logger.warn("Media work ID #{m&.id.to_s} (media type #{media_type.to_s}) has no FileSets")
        n += 1
      else
        fs_error = false

        m.file_sets.each do |fs|
          if !fs.original_file.presence
            Rails.logger.warn("Media work ID #{m&.id.to_s} (media type #{media_type.to_s}) has FileSet (ID: #{fs.id}), but FileSet lacks original_file")
            fs_error = true
          end
        end

        n += 1 if fs_error
      end
    end

    Rails.logger.warn("#{n} Media works lack FileSets or have FileSets missing original_file")
  end

  desc 'Mass ingest data'
  task :mass_ingest, [:admin_email, :update, :update_only_if_no_file] => :environment do |task, args|
    u = User.find_by(email: args[:admin_email])
    if args[:update].present? && args[:update].to_i == true
      update = true
    else
      update = false
    end
    if args[:update_only_if_no_file].present? && args[:update_only_if_no_file].to_i == true
      update_only_if_no_file = true
    else
      update_only_if_no_file = false
    end
    MassIngestJob.perform_later({
      csv_path: File.expand_path("tmp/ingest/"),
      admin_email: u,
      update: update,
      update_only_if_no_file: update_only_if_no_file
    })
  end

  desc 'Mass ingest data not in a job context'
  task :mass_ingest_no_job, [:admin_email, :update, :update_only_if_no_file]  => :environment do |task, args|
    u = User.find_by(email: args[:admin_email])
    if args[:update].present? && args[:update].to_i == 1
      update = true
    else
      update = false
    end
    if args[:update_only_if_no_file].present? && args[:update_only_if_no_file].to_i == 1
      update_only_if_no_file = true
    else
      update_only_if_no_file = false
    end
    Ms1to2::Importer.new(File.expand_path("tmp/ingest/"), u, update, update_only_if_no_file).call
  end

  desc 'Mass ingest work relationships'
  task :mass_ingest_relationships, [:input_csv] => :environment do |task, args|
    input_csv = args[:input_csv]
    Ms1to2::ImportWorkRelationships.new(input_csv).call
  end

  desc 'Mass ingest collection membership'
  task :mass_ingest_collection_membership, [:input_csv] => :environment do |task, args|
    input_csv = args[:input_csv]
    Ms1to2::ImportCollectionMembers.new(input_csv).call
  end

  desc 'Mass media metadata update'
  task :mass_update_all_media_metadata, [:input_csv] => :environment do |task, args|
    input_csv = args[:input_csv]
    Ms1to2::UpdateAllMediaMetadata.new(input_csv).call
  end

  desc 'Update blank organization institution and collection codes'
  task :fix_organization_blanks => :environment do
    Organization.all.each do |o|
      changed = false
      if o.institution_code.include?('blank')
        o.institution_code = o.institution_code.map { |x| x == 'blank' ? '' : x }
        changed = true
      end
      if o.collection_code.include?('blank')
        o.collection_code = o.collection_code.map { |x| x == 'blank' ? '' : x }
        changed = true
      end
      o.save! if changed
    end
  end

  desc 'Transfer Imaging Event Device parent IDs to IE device_id metadata property'
  task :transfer_ie_parent_to_metadata => :environment do
    ImagingEvent.find_each do |ie|
      ie.member_of.each do |parent|
        if parent.class == Device
          puts("Adding device parent #{parent.id} to imaging event #{ie.id}")
          ie.device_id = [parent.id]
          ie.save!
        end
      end
    end
  end

  desc 'Transfer Imaging Event Device parent physical object IDs to IE physical_object_id metadata property'
  task :transfer_ie_parent_po_to_metadata => :environment do
    ImagingEvent.find_each do |ie|
      po_id = ie.member_of.map { |p| p.id if ( p.class == BiologicalSpecimen || p.class == CulturalHeritageObject ) }.compact
      if po_id.present?
        UpdateImagingEventMetadataJob.perform_later({
          id: [ie.id],
          physical_object_id: po_id
        })
      end
    end
  end

  desc 'Transfer Physical Object Organization parent IDs to PO organization_id metadata property'
  task :transfer_po_parent_to_metadata => :environment do
    BiologicalSpecimen.find_each do |b|
      org_ids = b.organization_id + b.
        member_of.
        map { |p| p.id if ( p.class == Organization && !b.organization_id.include?(p.id) ) }.
        compact
      if org_ids.present?
        puts("Adding organizations #{org_ids.join(', ')} to BSO #{b.id}")
        b.organization_id = org_ids
        b.save!
      end
    end
    CulturalHeritageObject.find_each do |c|
      org_ids = c.organization_id + c.
        member_of.
        map { |p| p.id if ( p.class == Organization && !c.organization_id.include?(p.id) ) }.
        compact
      if org_ids.present?
        puts("Adding organizations #{org_ids.join(', ')} to CHO #{c.id}")
        c.organization_id = org_ids
        c.save!
      end
    end
  end

  desc 'Transfer Physical Object Taxonomy parent to PO taxonomy_id metadata property'
  task :transfer_po_parent_taxonomy_to_metadata => :environment do
    BiologicalSpecimen.find_each do |b|
      taxonomy_id = b.taxonomy_id + b.
        member_of.
        map { |p| p.id if ( p.class == Taxonomy && !b.taxonomy_id.include?(p.id) ) }.
        compact
      if taxonomy_id.present?
        UpdateBiologicalSpecimenMetadataJob.perform_later({
          id: [b.id],
          taxonomy_id: taxonomy_id
        })
      end
    end
  end

  desc 'Dissolve parent/child relationships between devices and imaging events'
  task :remove_device_ie_relationships => :environment do
    Device.find_each do |d|
      puts("Removing children from device #{d.id}")
      d.ordered_members = []
      d.members = []
      d.save!
    end
  end

  desc 'Dissolve parent/child relationships between POs and imaging events'
  task :remove_po_ie_relationships => :environment do
    BiologicalSpecimen.find_each do |b|
      puts("Removing children from BSO #{b.id}")
      b.ordered_members = []
      b.members = []
      b.save!
    end
    CulturalHeritageObject.find_each do |c|
      puts("Removing children from CHO #{c.id}")
      c.ordered_members = []
      c.members = []
      c.save!
    end
  end

  desc 'Dissolve parent/child relationships between organizations and objects'
  task :remove_organization_object_relationships => :environment do
    Organization.find_each do |o|
      puts("Removing BSO and CHO children from organizaiton #{o.id}")
      new_members = Array(o.ordered_members)
        .select { |m| m.class != BiologicalSpecimen && m.class != CulturalHeritageObject }
        .compact
      o.ordered_members = new_members
      o.members = new_members
      o.save!
    end
  end

  desc 'Dissolve parent/child relationships between taxonomies and objects'
  task :remove_taxonomy_object_relationships => :environment do
    Taxonomy.find_each do |t|
      puts("Removing BSO children from taxonomy #{t.id}")
      t.ordered_members = []
      t.members = []
      t.save!
    end
  end

  desc 'Set up MS email user'
  task :create_email_sender_user => :environment do 
    if Hyrax.config.contact_email.present? && !User.find_by(email: Hyrax.config.contact_email)
      User.create(email: Hyrax.config.contact_email, password: Morphosource.ms_init_pw)
    end
  end

  desc 'Set up MS dev team user accounts'
  task :create_production_users => :environment do
    emails = Morphosource.ms_init_usr.split(',')
    password = Morphosource.ms_init_pw
    admin = Role.where("name = 'admin'")[0] || Role.create(name: 'admin')
    emails.each do |email|
      if !User.find_by(email: email)
        User.create(email: email, password: password)
      end
      admin.users << User.find_by(email: email)
    end
    admin.save

    # account for accessibility testing
    test_usr = Morphosource.ms_test_usr
    test_pw = Morphosource.ms_test_pw
    if !User.find_by(email: test_usr)
      User.create(email: test_usr, password: test_pw)
    end

    # create email sender user
    Rake::Task['morphosource:create_email_sender_user'].invoke
  end

  desc 'Set up MS development user accounts'
  task :create_development_users => :environment do
    defaults = Morphosource::Users::Defaults
    # create user accounts
    admin = User.create(defaults::ADMIN)
    contributor = User.create(defaults::CONTRIBUTOR)
    registered = User.create(defaults::REGISTERED)
    # assign admin to admin role
    admins = Role.find_or_create_by(name: 'admin')
    admins.users += [admin]
    admins.save
    # assign contributor to contributor role
    contributors = Role.find_or_create_by(name: 'contributor')
    contributors.users += [contributor]
    contributors.save

    # create email sender user
    Rake::Task['morphosource:create_email_sender_user'].invoke
  end

  desc 'Re-index specified model, one job per doc'
  task :update_index_by_model, [:model, :perdoc] => :environment do |task, args|
    class_eval <<-RUBY
    def model
      #{args[:model]}
    end
    RUBY
    if args[:perdoc].present? && args[:perdoc] == 'true'
      per_doc = true
    else
      per_doc = false
    end
    if model.present?
      if per_doc == false
        Rails.logger.warn ("Re-indexing all #{args[:model]}... ")
        UpdateAllModelWorksIndexesJob.perform_later(args[:model])
        Rails.logger.warn ("Re-indexing #{args[:model]} completed ")
      else
        model.find_each do |o|
          Rails.logger.warn ("Re-indexing begin: #{args[:model]} id:#{o.id}")
          UpdateWorkIndexJob.perform_later(o.id)
          Rails.logger.warn ("Re-indexing done: #{args[:model]} id:#{o.id}")
        end
      end
    else
      Rails.logger.warn("No valid model specified.")
    end
  end

  desc 'Run InheritPermissionsJob on all media'
  task :inherit_permissions_on_media => :environment do
    Media.find_each do |m|
      Rails.logger.warn ("Running InheritPermissionsJob on id:#{m.id}")
      InheritPermissionsJob.perform_later(m)
    end
  end

  desc 'Set up Admin Role'
  task :create_admin_role => :environment do
    Role.find_or_create_by(name: 'admin')
  end

  desc 'Set up Team and Project collection types'
  task :create_collection_types => :environment do
    if !Hyrax::CollectionType.where(title: Morphosource::CollectionTypes::Teams::SETTINGS[:title]).present?
      team = Hyrax::CollectionType.create(Morphosource::CollectionTypes::Teams::SETTINGS)
      Hyrax::CollectionTypes::CreateService.add_default_participants(team.id)
    end
    if !Hyrax::CollectionType.where(title: Morphosource::CollectionTypes::Projects::SETTINGS[:title]).present?
      project = Hyrax::CollectionType.create(Morphosource::CollectionTypes::Projects::SETTINGS)
      Hyrax::CollectionTypes::CreateService.add_default_participants(project.id)
    end
  end

  desc 'Set Up Batch Submission Contributor Role'
  task :create_batch_submission_contributor_role => :environment do
    Role.find_or_create_by(name: 'batch_submission_contributor')
  end

  desc 'Set Up Contributor Role'
  task :create_contributor_role => :environment do
    Role.find_or_create_by(name: 'contributor')
  end

  desc 'Set Up Fund Code Charge API User Role'
  task :create_charge_api_role => :environment do
    Role.find_or_create_by(name: 'charge_api')
  end

  desc 'Update reviewers column for all cart items'
  task :update_cartitem_reviewers => :environment do
    CartItem.find_each do |item|
      unless item.date_downloaded.present?
        begin
          media = Media.find(item.work_id)
          if media.present?
            item.reviewers = media.reviewer
            item.save
            puts("CartItem #{item.id} updated")
          end
        rescue
          puts "Exception on finding media #{item.work_id}"
          # most likely LDP gone exception
        end
      end
    end
  end

  desc 'Find, generate and assign 2D preview images for project media'
  task :find_and_set_preview_for_project_media, [:project_id, :delete_only, :delete_dry_run] => :environment do |task, args|

    project_id = args[:project_id]
    if project_id.nil?
      puts "no project ID"
    else

      if args[:delete_only].present? && args[:delete_only] == "true"
        delete_only = true
      else
        delete_only = false
      end
      puts "delete_only = " + delete_only.to_s
      if args[:delete_dry_run].present? && args[:delete_dry_run] == "true"
        delete_dry_run = true
      else
        delete_dry_run = false
      end
      puts "delete_dry_run = " + delete_dry_run.to_s

      match_media = {}
      report_list = []
      proj_image_qry = "member_of_project_ids_ssim:#{project_id} AND has_model_ssim:Media AND media_type_tesim:Image"
      media_solr = ActiveFedora::SolrService.query(proj_image_qry, rows: 999999)
      media_solr.each do |image_media_hit|
        image_media = Media.find(image_media_hit.id)
        image_pe = ProcessingEvent.where('member_ids_ssim' => image_media.id)&.first
        if image_pe.present?
          ie = ImagingEvent.where('member_ids_ssim' => image_pe.id)&.first
        end
        if ie.present?
          pe_list = ie.members.select{ |o| o.processing_event? }
          image_list = []
          mesh_list = []
          pe_list.each do |p|
            medias = p.members.select{ |o| o.media? }
            medias.each do |m|
              if m.media_type == ["Image"]
                image_list << m.id
              elsif m.media_type == ["Mesh"]
                mesh_list << m.id
              end
            end
          end
          if image_list.count == 1 && mesh_list.count == 1 && image_list.first == image_media.id
            if delete_only == true
              puts 'Deleting Image ' + image_media.id
              unless delete_dry_run == true
                image_media.destroy
                puts 'Image ' + image_media.id + ' destroyed'
              end
            else
              match_media[mesh_list.first] = image_media.id
              puts 'MATCH: Image ' + image_media.id + ' will be set as preview for Mesh ' + mesh_list.first
              mesh_media = Media.find(mesh_list.first)

              fs = image_media.file_sets&.first
              if fs.present?
                new_thumbnail_path = Morphosource::DerivativePath.derivative_path_for_reference(fs.id, 'thumbnail')
                mesh_thumbnail_path = Hyrax::DerivativePath.derivative_path_for_reference(mesh_media, 'thumbnail')
                FileUtils.mkdir_p(File.dirname(mesh_thumbnail_path))
                mesh_thumbnail_url = "file://#{mesh_thumbnail_path}"
                begin
                  ::Morphosource::Derivatives::CroppedImageDerivatives.create(
                    new_thumbnail_path,
                    outputs: [{
                      label: :thumbnail,
                      url: mesh_thumbnail_url,
                    }]
                    )

                  mesh_media.thumbnail_id = mesh_media.id
                  mesh_media.save
                  puts 'SAVED: Mesh ' + mesh_media.id + ' with Preview Image ' + image_media.id
                rescue Exception => e
                  puts "Exception calling CroppedImageDerivatives.create on Mesh " + mesh_media.id + ": " + e.message
                end

              else
                puts "File sets not present for Image : " + image_media.id
              end

            end

          else

            puts 'REPORT: IE ' + ie.id + ' has ' + mesh_list.count.to_s + ' mesh type media '
            puts mesh_list.join(', ')
            puts 'REPORT: IE ' + ie.id + ' has ' + image_list.count.to_s + ' image type media '
            puts image_list.join(', ')
            report_list << ie.id
          end
        end

      end
      puts "MATCH MEDIA COUNT: " + match_media.count.to_s
      puts "REPORT COUNT: " + report_list.count.to_s

    end
  end # /find_and_set_preview_for_project_media

  desc 'Update media ip holder field'
  task :update_media_ip_holder => :environment do
    # find media with rights holder metadata with 'Name:' format
    ids = Morphosource::SolrService.new.get_docs("rights_holder_tesim:Name:").map{|d| d["id"]}
    ids.each do |id|
      m = Media.find(id)
      # ex: ["Name: Name1, Type: Copyright and License", "Name: Name3, Type: License", "Name: Name2, Type: Copyright"]
      rights_holder = m.rights_holder
      # double-check it is name-type format
      next unless (rights_holder.first.include?("Name: ") && rights_holder.first.include?("Type: "))
      # assemble new rights_holder
      new_rh = rights_holder.each_with_object([]) do |rh, new_rights_holder|
        name = /(?<=^Name: ).*?(?=, Type: )/.match(rh)
        type = /(?<=, Type: ).*?(\z)/.match(rh)
        next if (name.nil? || name[0].empty?)
        if type.nil? || type[0].empty?
          new_rights_holder << name[0].strip
        else
          new_rights_holder << name[0].strip.concat(" (#{type[0]})").strip
        end
      end
      m.rights_holder = new_rh
      m.save!
    end
  end

  desc 'Create new fund code billing cycle (dates in m/d/Y format)'
  task :create_new_fund_code_billing_cycle, [:start_date, :end_date] => :environment do |task, args|
    start_date = args[:start_date].present? ? Date.strptime(args[:start_date], '%m/%d/%Y') : nil
    end_date   = args[:end_date].present?   ? Date.strptime(args[:end_date], '%m/%d/%Y')   : nil
    Morphosource::FundCodes::BillingCycleService.call(custom_start_date: start_date, custom_end_date: end_date)
  end

  desc 'Find solr documents corresponding to deleted fedora objects'
  task :find_extra_solr_records => :environment do
    Morphosource::FindExtraSolrJob.perform_later
    puts "Checking for extra solr docs. When complete, results will be written to extra_solr_docs.txt"
  end

  desc "Update access to physical objects for org-linked teams"
  task :update_org_linked_po_access, [:update] => :environment do |task, args|
    if args[:update].present? && args[:update] == 'true'
      update = true
    else
      update = false
    end
    # update all bso and cho with org linked team
    qry = "linked_organization_id_ssi:* AND has_model_ssim:Collection AND collection_type_gid_ssim:\"gid://morpho-source-sf/hyrax-collectiontype/1\""
    result = ActiveFedora::SolrService.query(qry, rows: 999999)
    puts "#{result.count} org-linked teams found "
    result.each do |hit|
      team = Collection.find(hit.id)
      if team.present?
        UpdateOrgLinkedTeamPoJob.perform_now(team, update)
      end
    end
  end

  desc "Update access to media for org-linked teams"
  task :update_org_linked_media_access, [:po_type, :update] => :environment do |task, args|
    po_type = args[:po_type]
    if po_type == 'BSO'
      po_type_qs = "Biological Specimen"
    elsif po_type == 'CHO'
      po_type_qs = "Cultural Heritage Object"
    else
      po_type_qs = nil
    end
    if args[:update].present? && args[:update] == 'true'
      update = true
    else
      update = false
    end
    # update all bso and cho with org linked team
    qry = "linked_organization_id_ssi:* AND has_model_ssim:Collection AND collection_type_gid_ssim:\"gid://morpho-source-sf/hyrax-collectiontype/1\""
    result = ActiveFedora::SolrService.query(qry, rows: 999999)
    puts "#{result.count} org-linked teams found "
    result.each do |hit|
      team = Collection.find(hit.id)
      if team.present?
        UpdateOrgLinkedTeamMediaJob.perform_now(po_type_qs, team, update)
      end
    end
  end

  desc "Update specimens from IDigbio"
  task :update_bso_from_idigbio, [:update, :project_id] => :environment do |task, args|
    log_file = 'log/idigbio_update_' + Time.now.strftime("%m-%d-%Y_%H-%M") + '.log'
    log = Logger.new(log_file)
    if args[:update].present? && args[:update] == 'true'
      update = true
    else
      update = false
    end
    if args[:project_id].present?
      # update bso associated with the project
      project_id = args[:project_id]
      qry = "media_member_of_project_ids_ssim:#{project_id} AND has_model_ssim:BiologicalSpecimen"
      result = ActiveFedora::SolrService.query(qry, rows: 999999)
      log.debug "#{result.count} specimens found for #{project_id}..."
      result.each do |hit|
        o = BiologicalSpecimen.find(hit.id)
        if o.present?
          log.debug "Updating specimen #{o.id} of project #{project_id} from IDigbio"
          UpdateBsoFromIdigbioJob.perform_later(o, update, true, log)
        else
          log.debug "Specimen #{o.id} not found"
        end
      end
    else
      # update all bso
      BiologicalSpecimen.find_each do |o|
        log.debug "Updating specimen #{o.id} from IDigbio"
        UpdateBsoFromIdigbioJob.perform_later(o, update, true, log_file)
      end
    end
  end

end