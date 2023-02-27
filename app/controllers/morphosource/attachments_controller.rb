module Morphosource
  class AttachmentsController < Hyrax::DownloadsController
    # Renders attachment files
    def show
      if file.is_a? String
        # For derivatives stored on the local file system
        send_local_content
      else
        send_file_not_found_image
      end
    end

    private
      # Override authorize_download! to use the :read permission instead of the :download permission
      def authorize_download!
        authorize! :read, params[asset_param_key]
      rescue CanCan::AccessDenied
        send_file_not_found_image
      end

      def file
        @file ||= load_file
      end

      def load_file
        field_reference = params[:field]
        return nil unless field_reference.present?
        file_path = Morphosource::AttachmentPath.attachment_for_field(params[asset_param_key], field_reference)
        ( file_path.present? && File.exist?(file_path) ) ? file_path : nil
      end

      def send_file_not_found_image
        file_not_found_image = Rails.root.join("app", "assets", "images", "us_404.png")
        send_file file_not_found_image, :type => 'image/png', :disposition => 'inline', :status => 404
      end
  end
end