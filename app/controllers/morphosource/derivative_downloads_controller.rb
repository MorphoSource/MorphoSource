module Morphosource
  class DerivativeDownloadsController < Hyrax::DownloadsController
    include Morphosource::TemporaryAccess::MediaControllerBehavior

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
      # Override authorize_download! to use the :read permission instead of the :download permission
      def authorize_download!
        file_reference = params[:file]
        if file_reference == 'thumbnail'
          asset_id = params[asset_param_key]
        else
          file_set = file_set_from_access_control_id(params[asset_param_key])
          asset_id = file_set.present? ? file_set.id : nil
        end

        # check for temporary access cookie if necessary
        if !can?(:read, asset_id)
          if file_reference == 'thumbnail'
            media = Media.find(asset_id) if Media.exists?(asset_id)
          else
            media = file_set&.member_of&.first
          end

          authorize_with_temporary_link_if_present(media.id) if media.present?
        end

        authorize! :read, asset_id
      rescue CanCan::AccessDenied
        unauthorized_image = Rails.root.join("app", "assets", "images", "default.png")
        send_file unauthorized_image, status: :unauthorized
      end
  
      def file
        @file ||= load_file
      end
  
      def load_file
        file_reference = params[:file]
        return default_file unless file_reference
        if file_reference == 'thumbnail'
          file_path = Morphosource::DerivativePath.derivative_path_for_reference(params[asset_param_key], file_reference)
          return Rails.root.join("app", "assets", "images", "work.png").to_s if !File.exist?(file_path)
        else
          file_set = file_set_from_access_control_id(params[asset_param_key])
          return default_file unless file_set && file_set.id
          file_path = Morphosource::DerivativePath.derivative_path_for_reference(file_set.id, file_reference)
        end
        File.exist?(file_path) ? file_path : nil
      end
  
      def file_set_from_access_control_id(access_control_id)
        FileSet.where(accessControl_ssim: access_control_id)&.first
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