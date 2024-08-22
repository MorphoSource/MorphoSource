# Override BrowseEverythingController to customize engine controller behavior
load BrowseEverything::Engine.root.join('app/controllers/browse_everything_controller.rb')
BrowseEverythingController.class_eval do
  def browser
    if ( 
      Hyrax.config.enable_browse_everything_file_system &&
      current_user &&
      current_user.globus_file_submitter? &&
      sftp_share_valid?(current_user&.sftp_share)
    )
      user_fs_config = { file_system: { home: current_user.sftp_share } }

      BrowserFactory.build(
        session: session, 
        url_options: BrowseEverything.config.merge(user_fs_config).merge(url_options: url_options)
      )
    else
      BrowserFactory.build(session: session, url_options: url_options)
    end
  end

  def sftp_share_valid?(path)
    path.present? && (Dir.exist?(Hyrax.config.sftp_share_root + path) || Dir.exist?(path))
  end
end  