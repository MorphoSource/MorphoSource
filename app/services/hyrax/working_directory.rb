# frozen_string_literal: true
module Hyrax
  # @deprecated Use JobIoWrapper instead
  class WorkingDirectory
    class << self
      # Returns the file passed as filepath if that file exists. Otherwise it grabs the file from repository,
      # puts it on the disk and returns that path.
      # @param [String] repository_file_id identifier for Hydra::PCDM::File
      # @param [String] id the identifier of the FileSet
      # @param [String, NilClass] filepath path to existing cached copy of the file
      # @return [String] path of the working file
      def find_or_retrieve(repository_file_id, id, filepath = nil)
        if filepath && File.exist?(filepath)
          Rails.logger.debug "in WorkingDirectory: filepath #{filepath} exists. Returning filepath..." 
          return filepath 
        end
        repository_file = Hydra::PCDM::File.find(repository_file_id)
        working_path = full_filename(id, repository_file.original_name)
        if File.exist?(working_path)
          Rails.logger.debug "in WorkingDirectory: #{repository_file.original_name} already exists in the working directory at #{working_path}"
          return working_path
        end
        copy_repository_resource_to_working_directory(repository_file, id)
      end

      # @param [Hydra::PCDM::File] file the resource in the repo
      # @param [String] id the identifier
      def copy_repository_resource_to_working_directory(file, id)
        Rails.logger.debug "in WorkingDirectory: Loading #{file.original_name} (#{file.id}) from the repository to the working directory"
        copy_stream_to_working_directory(file, id)
      end

      private

      # @param [Hydra::PCDM::File] file the resource in the repo
      # @param [String] id the identifier
      def copy_stream_to_working_directory(file, id)
        working_path = full_filename(id, file.original_name)
        Rails.logger.debug "in WorkingDirectory: Writing #{file.original_name} to the working directory at #{working_path}"
        FileUtils.mkdir_p(File.dirname(working_path))
        file_set = ::FileSet.find(id)

        File.open(working_path, 'wb') do |f|
          write_to_temp_file(file, f, file_set)
        end
        working_path
      end

      def write_to_temp_file(file, temp_file, file_set)
        if file_set&.is_remote_backed?
          stream_remote_url(file.original_name, temp_file)
        else
          stream_fedora_file(file, temp_file)
        end
      end

      def stream_fedora_file(file, temp_file)
        file.stream.each do |chunk|
          temp_file.write(chunk)
        end
      end

      def stream_remote_url(url, temp_file, redirect_limit = 3)
        raise ArgumentError, 'HTTP redirect too deep' if redirect_limit.zero?
        uri = URI.parse(url)
        Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
          request = Net::HTTP::Get.new(uri, remote_request_headers)
          http.request request do |response|
            case response
            when Net::HTTPSuccess
              response.read_body do |chunk|
                temp_file.write(chunk)
              end
            when Net::HTTPRedirection
              new_url = response['location']
              stream_remote_url(new_url, temp_file, redirect_limit - 1)
            else
              raise "Couldn't get data from remote URL (#{url}). Response: #{response.code}"
            end
          end
        end
      end

      def remote_request_headers
        Hyrax.config.remote_request_headers || {}
      end

      def full_filename(id, original_name)
        pair = id.scan(/..?/).first(4).push(id)
        File.join(Hyrax.config.working_path, *pair, original_name)
      end
    end
  end
end
