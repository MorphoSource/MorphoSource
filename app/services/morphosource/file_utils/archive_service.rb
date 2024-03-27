module Morphosource
  module FileUtils
    # Identifies and extracts archive files across multiple archive file formats
    class ArchiveService
      attr_reader :file, :all_contents_files, :all_contents_file_count, 
        :matching_contents_file_count, :matching_contents_file_groups

      def initialize(file)
        @file = file
      end

      # @!group Archive reading

      def read_archive(&block)
        if zip?
          read_zip(&block)
        elsif tar?
          read_tar(&block)
        end
      end

      def read_zip(&block)
        archive_type = :zip
        Zip::File.open(file) do |zip|
          yield(zip, archive_type) if block_given?
        end
      end

      def read_tar(&block)
        archive_type = :tar
        Archive::Tar::Minitar.open(file) do |tar|
          yield(tar, archive_type) if block_given?
        end
      end

      # @!endgroup
      # @!group Archive extraction
    
      def extract_archive(extract_dest, files_to_extract = [], preserve_dir_structure = true)
        raise "Destination to extract files is not a valid directory" if !Dir.exist?(extract_dest)
        if zip?
          extract_zip(extract_dest, files_to_extract, preserve_dir_structure)
        elsif tar?
          extract_tar(extract_dest, files_to_extract, preserve_dir_structure)
        end
      end

      def extract_zip(extract_dest, files_to_extract = [], preserve_dir_structure = true)
        files_extracted = []
        read_zip do |zip, _|
          # Iterate through input files list or through entire zip
          zip_files = files_to_extract.present? ? files_to_extract : zip
          zip_files.each do |f|
            f_name = f.respond_to?(:name) ? f.name : f
            next if File.basename(f_name).start_with?('.')
            f_subpath = preserve_dir_structure ? f_name : File.basename(f_name)
            f_path = File.join(extract_dest, f_subpath)
            zip.extract(f, f_path)
            files_extracted << f_path
          end
        end
        return files_extracted
      end

      def extract_tar(extract_dest, files_to_extract = [], preserve_dir_structure = true)
        files_extracted = []
        read_tar do |tar, _|
          tar.each do |f|
            next if File.basename(f.name).start_with?('.') || (f.respond_to?(:file?) && !f.file?)
            if !files_to_extract.present? || files_to_extract.include?(f.name)
              f_subpath = preserve_dir_structure ? f.name : File.basename(f.name)
              f_path = File.join(extract_dest, f_subpath)
              tar_write_entry(f.read, f_path)
              files_extracted << f_path
            end
          end
        end
        return files_extracted
      end

      def extract_single_file(extract_dest, file_name, preserve_dir_structure = true)
        f_subpath = preserve_dir_structure ? file_name : File.basename(file_name)
        f_path = File.join(extract_dest, f_subpath)

        read_archive do |archive, archive_type|
          if archive_type == :zip
            archive.extract(file_name, f_path)
          elsif archive_type == :tar
            archive.each do |f|
              next if File.basename(f.name).start_with?('.') || (f.respond_to?(:file?) && !f.file?)
              if f.name == file_name
                tar_write_entry(f.read, f_path)
              end
            end
          end
        end
      end

      # Given file data, write to file path, creating directories as needed
      def tar_write_entry(f_data, f_path)
        # Create dir(s) if needed
        dir_path = File.dirname(f_path)
        unless File.directory?(dir_path)
          ::FileUtils.mkdir_p(dir_path)
        end

        File.new(f_path, 'wb')
        File.open(f_path, 'wb') do |output_file|
          output_file.write(f_data)
        end
      end

      # @!endgroup
      # @!group Utility methods

      # returns either an IO stream (zip) or file data (tar)
      def get_contents_file(file_name)
        read_archive do |archive, archive_type|
          if archive_type == :zip
            return archive.get_input_stream(file_name)
          elsif archive_type == :tar
            archive.each do |f|
              next if File.basename(f.name).start_with?('.') || (f.respond_to?(:file?) && !f.file?)
              if f.name == file_name
                return f.read
              end
            end
          end
        end
      end

      # iterate through archive files, ignoring relative paths
      def each_file(&block)
        read_archive do |archive, archive_type|
          archive.each do |f|
            next if File.basename(f.name).start_with?('.') || (f.respond_to?(:file?) && !f.file?)
            yield(f)
          end
        end
      end

      # return largest group of same-type files in same location, with min num of files cut-off
      # file_exts: acceptable file types for finding
      # cutoff: this many or more files are required for group to be discovered
      # cutoff_exception_exts: files of these exts will be reported even if fewer than cutoff
      def largest_file_group(file_exts, cutoff: 20, cutoff_exception_exts: [])
        group_files_by_type_and_location(file_exts)

        # find largest sub-group for each file ext, if num files >= cutoff or file ext is an exception
        largest_group_by_ext = {}
        matching_contents_file_groups.each do |k, v|
          max = v.max_by { |sub_k, sub_v| sub_v.length }
          largest_group_by_ext[k] = max[1] if (max[1].length >= cutoff || cutoff_exception_exts.include?(k.downcase))
        end

        # return most preferred file group of sufficient size or exceptionality
        chosen_ext = file_exts.find { |ext| largest_group_by_ext.key?(ext) }
        if chosen_ext
          return largest_group_by_ext[chosen_ext], chosen_ext
        else
          return [], nil
        end
      end

      # given a list of file formats, return hash of groups of files of same format in same locations
      def group_files_by_type_and_location(file_exts)
        file_exts = file_exts.map(&:downcase)

        matching_file_groups = {}
        matching_file_count = 0
        all_files = []

        each_file do |file|
          all_files << file.name

          ext = File.extname(file.name).downcase
          if file_exts.include? ext
            matching_file_count += 1
            loc = File.dirname(file.name)
            matching_file_groups[ext] ||= {}
            matching_file_groups[ext][loc] ||= []
            matching_file_groups[ext][loc] << file.name
          end
        end
        
        @matching_contents_file_groups = matching_file_groups
        @matching_contents_file_count = matching_file_count
        @all_contents_files = all_files
        @all_contents_files_count = all_files.length
      end

      def archive_ext
        File.extname(file).downcase
      end

      def tar?
        archive_ext == ".tar"
      end

      def zip?
        archive_ext == ".zip"
      end
    end
  end
end
