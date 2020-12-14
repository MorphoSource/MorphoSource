require 'morphosource'
require 'ms1to2'
require 'importer'

namespace :morphosource do

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

  desc 'Loop over media and update all media-work physical object ID references'
  task :update_media_physical_object_ids => :environment do
    Media.all.each do |m| 
      Rails.logger.warn("Updating physical object ID for media #{m.id}") 
      m.update_physical_object_id
    end
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
  end

  desc 'Re-index specified model'
  task :update_index_by_model, [:model] => :environment do |task, args|
    class_eval <<-RUBY
    def modelClass
      #{args[:model]}
    end
    RUBY
    if modelClass.present?
      Rails.logger.info "Re-indexing all #{args[:model]}... "
      UpdateWorkIndexJob.perform_later(args[:model])
      Rails.logger.info "Re-indexing #{args[:model]} completed "
    else
      Rails.logger.warn("No valid model specified.")      
    end
  end

  desc 'Set up Admin Role'
  task :create_admin_role => :environment do
    Role.find_or_create_by(name: 'admin')
  end

  desc 'Set up Team and Project collection types'
  task :create_collection_types => :environment do
    team = Hyrax::CollectionType.create(Morphosource::CollectionTypes::Teams::SETTINGS)
    project = Hyrax::CollectionType.create(Morphosource::CollectionTypes::Projects::SETTINGS)
    Hyrax::CollectionTypes::CreateService.add_default_participants(team.id)
    Hyrax::CollectionTypes::CreateService.add_default_participants(project.id)
  end

  desc 'Set Up Contributor Role'
  task :create_contributor_role => :environment do
    Role.find_or_create_by(name: 'contributor')
  end

  desc 'MorphoSource Setup'
  task :setup  => :environment do
    # default admin set
    Rake::Task["hyrax:default_admin_set:create"].invoke
    # team and project collection types
    Rake::Task['morphosource:create_collection_types'].invoke
    # admin role
    Rake::Task['morphosource:create_admin_role'].invoke
    # contributor role
    Rake::Task['morphosource:create_contributor_role'].invoke
  end

end
