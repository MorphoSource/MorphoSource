require_dependency Hyrax::Engine.config.root.join('app','controllers','hyrax','downloads_controller.rb').to_s
class Hyrax::DownloadsController
  # Renders derivatives by access_control_id only. Original downloads are disabled.
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
        authorize! :read, params[asset_param_key]
      else
        file_set = file_set_from_access_control_id(params[asset_param_key])
        file_set_id = file_set.present? ? file_set.id : nil
        authorize! :read, file_set_id
      end
    rescue CanCan::AccessDenied
      unauthorized_image = Rails.root.join("app", "assets", "images", "unauthorized.png")
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
end
