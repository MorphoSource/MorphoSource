# Override BrowseEverythingController to customize engine controller behavior
load BrowseEverything::Engine.root.join('app/controllers/browse_everything_controller.rb')
BrowseEverythingController.class_eval do
  def browser
    if ( 
      Hyrax.config.enable_browse_everything_file_system &&
      current_user &&
      current_user.globus_file_submitter? &&
      sftp_share_valid?(user_share_full_path)
    )
      user_fs_config = { file_system: { home: user_share_full_path } }

      BrowserFactory.build(
        session: session, 
        url_options: BrowseEverything.config.merge(user_fs_config).merge(url_options: url_options)
      )
    else
      BrowserFactory.build(session: session, url_options: url_options)
    end
  end

  def sftp_share_valid?(path)
    path.present? && Dir.exist?(path)
  end

  def user_share_full_path
    @user_share_full_path ||= begin
      user_set_path = current_user&.sftp_share
      if !user_set_path.present?
        nil
      elsif Dir.exist?(Hyrax.config.sftp_share_root + user_set_path)
        File.join(Hyrax.config.sftp_share_root, user_set_path, '/')
      elsif Dir.exist?(user_set_path)
        unless user_set_path.match(/^\//)
          # if relative path, change it to absolute
          File.join(Rails.root, user_set_path, '/')
        else
          File.join(user_set_path, '/')
        end
      else
        nil
      end
    end
  end
end  