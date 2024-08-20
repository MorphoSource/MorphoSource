module Hyrax
  class UploadsController < ApplicationController
    load_and_authorize_resource class: Hyrax::UploadedFile

    # Find pre-existing partial upload informatiom via file name and upload hash params
    def find
      return head(:bad_request) unless ( params[:file].present? && upload_hash_valid? )

      @upload = Hyrax::UploadedFile.find_by(file: params[:file], upload_hash: params[:upload_hash])
      raise CanCan::AccessDenied if ( @upload.present? && !current_user.can?(:find, @upload) )
    end

    def create
      return head(:bad_request) unless ( params[:files]&.first.present? && upload_hash_valid? )

      incoming_file = params[:files]&.first
      incoming_file_name = incoming_file.original_filename

      if Hyrax::UploadedFile.exists?(file: incoming_file_name, upload_hash: params[:upload_hash], user: current_user)
        # This is a new chunk to append to an existing file (probably)
        @upload = Hyrax::UploadedFile.find_by(file: incoming_file_name, upload_hash: params[:upload_hash], user: current_user)

        content_range = request.headers["CONTENT-RANGE"]
        chunk_initial_byte = content_range[/\ (.*?)-/,1].to_i

        current_size = @upload.file.size
        if current_size == chunk_initial_byte
          # new chunk confirmed, append
          File.open(@upload.file.url, "ab") { |f| incoming_file.to_io.each_line { |line| f.write(line) } }
        else
          # chunk can not be appended to existing file, maybe restart upload?
          if chunk_initial_byte == 0
            # weird, but restart the upload
            create_initial_upload
          else
            return head(:bad_request)
          end
        end
      else
        # Create a new upload
        create_initial_upload
      end
    end

    def destroy
      @upload.destroy
      head :no_content
    end

    private

    # Is upload hash present and is it a UUID?
    def upload_hash_valid?
      uuid_regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-5][0-9a-f]{3}-[089ab][0-9a-f]{3}-[0-9a-f]{12}$/i
      params[:upload_hash].present? && uuid_regex.match?(params[:upload_hash].to_s.downcase)
    end

    def create_initial_upload
      @upload.attributes = { 
          file: params[:files].first,
          upload_hash: params[:upload_hash],
          user: current_user
        }
        @upload.save!
    end
  end
end
