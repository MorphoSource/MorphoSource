require 'morphosource'

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

end
