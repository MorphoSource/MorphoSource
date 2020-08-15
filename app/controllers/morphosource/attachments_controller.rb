module Morphosource
  class AttachmentsController < Hyrax::DownloadsController
    # Renders attachment files
    def show
      case file
      when ActiveFedora::File
        # For original files that are stored in fedora
        unauthorized_image = Rails.root.join("app", "assets", "images", "unauthorized.png")
        send_file unauthorized_image, status: :unauthorized
      when String
        # For derivatives stored on the local file system
        send_local_content
      else
        raise ActiveFedora::ObjectNotFoundError
      end 
    end

    private
      # Override authorize_download! to use the :read permission instead of the :download permission
      def authorize_download!
        authorize! :read, params[asset_param_key]
      rescue CanCan::AccessDenied
        unauthorized_image = Rails.root.join("app", "assets", "images", "unauthorized.png")
        send_file unauthorized_image, status: :unauthorized
      end

      def file
        @file ||= load_file
      end

      def load_file
        field_reference = params[:field]
        return nil unless field_reference
        file_path = Morphosource::AttachmentPath.attachment_for_field(params[asset_param_key], field_reference)
        File.exist?(file_path) ? file_path : nil
      end
  end
end