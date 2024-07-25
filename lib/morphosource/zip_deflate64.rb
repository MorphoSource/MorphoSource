module Morphosource
  # Handle DEFLATE64 ZIPs, for now only supports creating non-DEFLATE64 temp file copy
  class ZipDeflate64
    attr_reader :file, :file_md5, :file_name, :temp_dir, :temp_file_name, :temp_file_path

    def self.non_deflate_64_temp_file(file)
      new(file).non_deflate_64_temp_file
    end

    def initialize(file)
      @file = file
    end

    def non_deflate_64_temp_file
      create_temp_dir

      @file_name = File.basename(file, ".*")
      @file_md5 = Digest::MD5.file(file).hexdigest

      @temp_file_name = "#{file_name}_#{file_md5}.zip"
      @temp_file_path = Rails.root.join(temp_dir, temp_file_name)

      # If file already exists from previous run, return it now
      return temp_file_path if File.exists?(temp_file_path)

      create_non_deflate_64_temp_file
      if File.exists?(temp_file_path)
        return temp_file_path
      else
        raise "Error occurred finding or creating temp file from DEFLATE64 ZIP file"
      end  
    end

    def create_temp_dir
      @temp_dir = Rails.root.join(Hyrax.config.derivatives_tmp_path, "7zip_tmp")
      Dir.mkdir temp_dir unless File.exist? temp_dir
    end

    def create_non_deflate_64_temp_file
      begin 
        files_extract_path = Rails.root.join(temp_dir, "#{file_name}_#{file_md5}_extracted_files")
        Dir.mkdir files_extract_path unless File.exist? files_extract_path

        # Extract files from DEFLATE64 ZIP into working directory
        Morphosource::Derivatives::Extract7Zip.new(file, files_extract_path).call

        # Re-compress extracted files into temp file
        Morphosource::Derivatives::CompressZip.new(files_extract_path, temp_file_path).call
      ensure
        FileUtils.rm_r files_extract_path
      end
    end
  end
end