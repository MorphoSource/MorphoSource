module Morphosource
  class DerivativeDownloadsController < Hyrax::DownloadsController
    include Morphosource::TemporaryAccess::TemporaryAccessControllerBehavior

    before_action :load_file, :authorize_download!

    self.temporary_access_link_class = TemporaryMediaAccessLink

    def show
      case file
      when ActiveFedora::File
        # For original files that are stored in fedora
        redirect_to '/'
      when String
        # For derivatives stored on the local file system
        headers['Access-Control-Allow-Origin'] = '*'
        send_local_content
      else
        raise ActiveFedora::ObjectNotFoundError
      end
    end
  
    private
      def load_file
        file_path = nil
        if file_reference == 'thumbnail'
          file_path = Morphosource::DerivativePath.derivative_path_for_reference(params[asset_param_key], file_reference)
        elsif file_set && file_set.id
          file_path = Morphosource::DerivativePath.derivative_path_for_reference(file_set.id, file_reference)
        end
        @file = ( file_path.present? && File.exist?(file_path) ) ? file_path : default_image
      end

      def file_set
        @file_set ||= file_set_from_access_control_id(params[asset_param_key])
      end

      def file_set_from_access_control_id(access_control_id)
        return nil unless access_control_id.present?
        FileSet.where(accessControl_ssim: access_control_id)&.first
      end

      def file
        @file ||= load_file
      end

      def authorize_download!
        if !can?(:read, asset_id) && any_temporary_link_cookie_exists?
          # don't bother checking if default image
          if file == default_image
            send_file_not_found_image and return
          end

          media_id = nil
          if file_reference == 'thumbnail'
            # In most cases, asset_id is Media, but sometimes is FileSet
            # Avoid calling .exists? since it's slow
            media_id = (FileSet.count(conditions: { id: asset_id }) == 1) ? FileSet.find(asset_id)&.member_of&.first&.id : asset_id
          elsif file_set.present?
            media_id = file_set&.member_of&.first&.id
          end

          authorize_media_with_temporary_link(media_id) if media_id.present?
        end

        authorize! :read, asset_id
      rescue CanCan::AccessDenied
        send_file_not_found_image
      end

      # For thumbnail, asset id is from param, otherwise file_set id from param access_control_id
      def asset_id
        @asset_id ||= ( file_reference == 'thumbnail' ) ? params[asset_param_key] : file_set_from_access_control_id(params[asset_param_key])&.id
      end

      def file_reference
        params[:file]
      end

      def default_image
        @default_image ||= Rails.root.join("app", "assets", "images", "work.png").to_s
      end

      def send_file_not_found_image
        send_file default_image, :type => 'image/png', :disposition => 'inline', :status => 404
      end
  
      def mime_type_for(file)
        case File.extname(file)
        when '.glb'
          'model/gltf+json'
        when '.dcm'
          'application/dicom'
        else
          MIME::Types.type_for(File.extname(file)).first.content_type
        end
      end
  end
end