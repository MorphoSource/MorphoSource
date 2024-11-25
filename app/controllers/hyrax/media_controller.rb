# Generated via
#  `rails generate hyrax:work Media`
module Hyrax
  # Generated controller for Media
  class MediaController < ApplicationController
    # Adds Hyrax behaviors to the controller
    include Morphosource::CurationConcernControllerBehavior
    include Morphosource::TemporaryAccess::TemporaryAccessControllerBehavior
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Hyrax::ChildWorkRedirect
    include Morphosource::CustomThumbnails
    include Morphosource::MessageHelper
    self.curation_concern_type = ::Media

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::MediaPresenter

    # override Hydra::AccessControlsEnforcement to include 'download' access in @discovery_permissions
    self.search_builder_class = Morphosource::WorkSearchBuilder

    self.temporary_access_link_class = TemporaryMediaAccessLink

    skip_authorize_resource only: [:showcase, :modal_file_archive_contents, :thumbnail]

    before_action :validate_individual_access, only: [:update]
    before_action :save_individual_access, only: [:update]
    before_action :save_fileset_visibility, only: [:update]
    before_action :set_fileset_visibility, only: [:create, :update]
    before_action :authorize_media_with_temporary_link, only: [:showcase]
    before_action :set_fund_code, only: [:update]
    after_action :update_thumbnail, only: [:update]
    after_action :deliver_individual_access_messages, only: [:update]

    # override the layout from WorksControllerBehavior
    def decide_layout
      layout = case action_name
               when 'show'
                 '1_column'
               when 'showcase'
                 'morphosource_2_columns'
               when 'edit'
                 'morphosource_2_columns'
               # in case we need to reference the old edit page. remove this action later
               when 'hyraxedit'
                 '1_column'
               when 'update'
                 'morphosource_2_columns'
               else
                 'dashboard'
               end
      File.join(theme, layout)
    end

    def showcase
      # note: most curation concern methods get concern from search_result_document(id: params[:id])
      # this refactors that - only for showcase method - to be more direct, like collections
      # if this works well, should refactor to use this across the board
      curation_concern_solr_doc = curation_concern.present? ? 
        ::SolrDocument.find(curation_concern.id) : ::SolrDocument.find(params[:id])
      raise CanCan::AccessDenied.new(nil, :show) unless (curation_concern && current_ability.can?(:read, curation_concern))

      @presenter = show_presenter.new(curation_concern_solr_doc, current_ability, request)
      set_flash
      render '/hyrax/media/showcase', presenter: @presenter
    end

    # dynamically loads archive file contents list for archive information modal
    def modal_file_archive_contents
      curation_concern_solr_doc = curation_concern.present? ? 
        ::SolrDocument.find(curation_concern.id) : ::SolrDocument.find(params[:id])
      raise CanCan::AccessDenied.new(nil, :show) unless (curation_concern && current_ability.can?(:read, curation_concern))

      @presenter = show_presenter.new(curation_concern_solr_doc, current_ability, request)

      respond_to do |format|
        format.js { render layout: false }
        format.html { render 'showcase'}
      end

    end

    # overriding action methods from works_controller_behavior.rb
    def edit
      build_form
      @presenter = show_presenter.new(search_result_document(id: params[:id]), current_ability, request)
      @member_of_collections_json = member_of_collections_json(@presenter.member_of_collection_presenters)  
      if (
        @presenter.imaging_event.present? && 
        (ie_work = ImagingEvent.find_by(id: @presenter.imaging_event.id)).present?
      )
        @imaging_event_form = Hyrax::WorkFormService.build(ie_work, current_ability, self)
      end

      if (
        @presenter.this_media_processing_event.present? && 
        (pe_work = ProcessingEvent.find_by(id: @presenter.this_media_processing_event[:id])).present?
      )
        @processing_event_form = Hyrax::WorkFormService.build(pe_work, current_ability, self)
      end

      @countries_service = Morphosource::CountriesService.new
      @new_processing_event_submit_submissions_url = '/submissions/new_processing_event_submit'
      @new_processing_event_form = Hyrax::WorkFormService.build(::ProcessingEvent.new, current_ability, self)
      set_flash
      render '/hyrax/media/edit', presenter: @presenter
    end

    def member_of_collections_json(member_of_collections)
      member_of_collections.map do |coll|
        {
          id: coll.id,
          label: coll.title.first,
          removable: current_user.can?(:edit, Collection.find(coll.id))
        }
      end.to_json
    end

    def set_flash
      added_flash = ""
      file_status = ""
      if flash[:notice].present?
        if flash[:notice].include? 'added'
          added_flash << " The file might take some time to be processed."
          file_status = "added"
        elsif flash[:notice].include? 'updated'
          added_flash << " Any updated file might take some time to be processed."
          file_status = "updated"
        elsif flash[:notice].include? 'deleted'
          file_status = "deleted"
        end
      else
        flash[:notice] = ""
      end
      @presenter.file_status = file_status
      flash[:notice] << added_flash
      flash[:error] ||= [] << get_remote_file_issues if get_remote_file_issues.present?
    end

    def get_remote_file_issues
      msg = ""
      if (issues = curation_concern.remote_file_health_details.split('; ')).present?
        if can? :edit, curation_concern.id
          msg = t('morphosource.media.remote_file_alert.edit_access_message') + ' Issue(s):' +
          '<ul class="align-li">'
          issues.each do |item|
            msg += '<li>' + item + '</li>'
          end
          msg += '</ul>'
        else
          msg = t('morphosource.media.remote_file_alert.general_message').html_safe
        end
      end
      msg
    end

    # in case we need to reference the old edit page. remove this action later
    def hyraxedit
      build_form
      @presenter = show_presenter.new(search_result_document(id: params[:id]), current_ability, request)
      render '/hyrax/base/edit', presenter: @presenter
    end

    # Overriding WorksControllerBehavior to add file format validation
    # Could not do this as an ActiveModel validation because new file uploads are not added until after create
    def create
      if file_formats_valid? && actor.create(actor_environment)
        after_create_response
      else
        respond_to do |wants|
          wants.html do
            build_form
            render 'new', status: :unprocessable_entity
          end
          wants.json { render_json_response(response_type: :unprocessable_entity, options: { errors: curation_concern.errors }) }
        end
      end
    end

    def update
      # Handle possible attachment upload
      if params[:media][:agreement_uri].present? && Morphosource::AttachmentService.get(curation_concern.id, 'agreement').present?
        Morphosource::AttachmentService.delete(curation_concern.id, 'agreement')
      elsif params[:agreement] && Morphosource.attachment_formats.include?(File.extname(params[:agreement].original_filename))
        Morphosource::AttachmentService.create(curation_concern.id, 'agreement', params[:agreement])
        params.delete(:agreement)
        params[:media][:agreement_uri] = ''
      elsif params[:media_attachment_delete] == 'delete'
        Morphosource::AttachmentService.delete(curation_concern.id, 'agreement')
        params.delete(:media_attachment_delete)
      end

      if file_formats_valid? && actor.update(actor_environment)
        after_update_response
      else
        respond_to do |wants|
          wants.html do
            build_form
            #render 'edit', status: :unprocessable_entity
            # todo: make sure to handle error when changing media type
            @presenter = show_presenter.new(search_result_document(id: params[:id]), current_ability, request)
            
            if (
              @presenter.imaging_event.present? && 
              (ie_work = ImagingEvent.find_by(id: @presenter.imaging_event.id)).present?
            )
              @imaging_event_form = Hyrax::WorkFormService.build(ie_work, current_ability, self)
            end
      
            if (
              @presenter.this_media_processing_event.present? && 
              (pe_work = ProcessingEvent.find_by(id: @presenter.this_media_processing_event[:id])).present?
            )
              @processing_event_form = Hyrax::WorkFormService.build(pe_work, current_ability, self)
            end

            @countries_service = Morphosource::CountriesService.new
            @new_processing_event_submit_submissions_url = '/submissions/new_processing_event_submit'
            @new_processing_event_form = Hyrax::WorkFormService.build(::ProcessingEvent.new, current_ability, self)

            render '/hyrax/media/edit', presenter: @presenter, status: :unprocessable_entity
          end
          wants.json { render_json_response(response_type: :unprocessable_entity, options: { errors: curation_concern.errors }) }
        end
      end
    end

    def after_destroy(works_to_index, works_to_delete)
      UpdateRelatedWorksIndexJob.perform_later(works_to_index.compact.map { |w| w.id })
      works_to_delete&.each do |w|
        w.delete if w.present?
      end
      respond_to do |format|
        format.js {render :js => "location.reload()"}
        format.html do
          flash[:notice] = 'Media deleted'
          redirect_to '/dashboard/my/media'
        end
        format.json { head :no_content, location: '/dashboard/my/media' }
      end
    end

    def after_destroy_error(id)
      respond_to do |format|
        format.html do
          flash[:notice] = 'Error deleting media'
          redirect_to '/concern/media/' + id + '/edit'
        end
        format.json { render json: { id: id }, status: :unprocessable_entity, location: media_showcase_path(curation_concern) }
      end
    end

    def destroy
      # delete the PE parent of that media
      # If the media has a direct or indirect IE parent and that IE parent has no other children, it should also be deleted
      processing_event = curation_concern.parent_works.select { |w| w.class == ProcessingEvent }&.first
      if processing_event.present?
        imaging_event = processing_event.parent_works.select { |w| w.class == ImagingEvent }&.first
      else
        imaging_event = curation_concern.parent_works.select { |w| w.class == ImagingEvent }&.first
      end
      if imaging_event.present?
        if imaging_event.descendants.select { |d| d.class == Media && d.id != curation_concern.id}.present?
          imaging_event = nil
        end
      end
      works_to_delete = [processing_event, imaging_event].compact
      works_to_index = (curation_concern.related_media + curation_concern.physical_objects).compact
      if curation_concern.destroy
        after_destroy(works_to_index, works_to_delete)
      else
        after_destroy_error(curation_concern.id)
      end
    end

    def mint_doi
      if current_user.admin?
        media_work = Media.find(params[:id])
        if media_work.doi.empty?
          minted_doi = media_work.mint_doi(main_app.media_showcase_url(id: params[:id]))
          # if minted_doi is an exception put the exception message in flash[:error]
          if minted_doi.respond_to?(:message)
            flash[:error] = minted_doi.message
          elsif minted_doi.nil?
            flash[:error] = "Error minting DOI"
          else
            flash[:notice] = "Minted DOI: #{minted_doi}"
          end
        else
          flash[:error] = "Error minting DOI: DOI already exists"
        end
      else
        flash[:error] = "Error minting DOI: you must be an administrator in order to assign DOIs"
      end
      redirect_to(main_app.media_showcase_path(id: params[:id])) and return
    end

    # disable manifest method since we are using a separate controller now
    def manifest
      redirect_to(main_app.media_showcase_path(id: params[:id])) and return
    end

    # media thumbnail route to get to 2D preview image
    def thumbnail
      if authorize!(:read, curation_concern)
        redirect_to(main_app.download_path(
          id: curation_concern.thumbnail.present? ? curation_concern.thumbnail.id : curation_concern.id,
          file: 'thumbnail'
        )) and return
      else
        redirect_to(main_app.media_showcase_path(id: curation_concern.id)) and return
      end
    end

    # characterize media fileset
    def characterize
      if current_user.admin?
        media_work = Media.find(params[:id])
        # Note: For remote file, the original_file.content is empty, therefore original_file.present? returns false 
        if media_work.is_remote_backed? 
          if !media_work.file_sets.first.present?
            flash[:error] = "Media has no FileSet. Characterization job not created."
          elsif JobIoWrapper.find_by(file_set_id: media_work.file_sets.first.id)&.path.present?
            PrepareCharacterizeJob.perform_later(media_work.file_sets.first.id)
            flash[:notice] = "Media characterization job has been started"
          else
            flash[:error] = "Characterization job not created. Try deleting and uploading the file again."
          end
        elsif media_work.file_sets.first.present? && media_work.file_sets.first.original_file.present?
          PrepareCharacterizeJob.perform_later(media_work.file_sets.first.id)
          flash[:notice] = "Media characterization job has been started"
        else
          flash[:error] = "Media has no FileSet or FileSet has no original file. Characterization job not created."
        end
      end
      redirect_to(main_app.media_showcase_edit_path(id: params[:id])) and return
    end

    # derive media fileset
    def create_derivatives
      if current_user.admin?
        media_work = Media.find(params[:id])
        if media_work.is_remote_backed? 
          if !media_work.file_sets.first.present?
            flash[:error] = "Media has no FileSet. Create derivatives job not created."
          elsif JobIoWrapper.find_by(file_set_id: media_work.file_sets.first.id)&.path.present?
            PrepareCreateDerivativesJob.perform_later(media_work.file_sets.first.id)
            flash[:notice] = "Media create derivatives job has been started"
          else
            flash[:error] = "Create derivatives job not created. Try deleting and uploading the file again."
          end
        elsif media_work.file_sets.first.present? && media_work.file_sets.first.original_file.present?
          PrepareCreateDerivativesJob.perform_later(media_work.file_sets.first.id)
          flash[:notice] = "Media create derivatives job has been started"
        else
          flash[:error] = "Media has no FileSet or FileSet has no original file, create derivatives job not started"
        end
      end
      redirect_to(main_app.media_showcase_edit_path(id: params[:id])) and return
    end

    private

      # Checks that uploaded files are the correct format for selected media type.
      def validate_file_formats
        files = []
        invalid_files = []
        media_type = attributes_for_actor["media_type"].first
        # New uploads

        if attributes_for_actor["uploaded_files"].present?
          attributes_for_actor["uploaded_files"].each do |file_id|
            files << Hyrax::UploadedFile.find(file_id)["file"]
          end
        elsif attributes_for_actor["remote_files"].present?
          # files uploaded from cloud
          attributes_for_actor["remote_files"].each do |f| 
            files << f["file_name"]
          end
        end

        # Previous uploads
        self.curation_concern.file_sets.each do |file_set|
          if file_set.original_file.present?
            files << file_set.original_file.original_name
          # if a recent upload hasn't been processed yet, use the title instead.
          elsif ( file_set.title.present? || file_set.label.present? )
            files << ( file_set.title&.first || file_set.label )
          end
        end

        files.each do |file|
          invalid_files << file unless Morphosource::MEDIA_FORMATS[media_type][:extensions].include? File.extname(file).downcase
        end

        if invalid_files.length != 0
          curation_concern.errors.add(:base, "Invalid files: #{invalid_files.uniq.join(', ')} for Media Type: #{Morphosource::MEDIA_FORMATS[media_type][:label]}.")
        end
      end

      def file_formats_valid?
        return true if params["commit"] == "Update Embargo" || params["commit"] == "Update Lease"
        validate_file_formats
        curation_concern.errors.empty?
      end

      def set_fileset_visibility
        selected_visibility = params["media"]["visibility"]
        unrestrictable_doi_visibilities = %w{open restricted_download preview_only hidden}
        if (!curation_concern.doi.empty?) && unrestrictable_doi_visibilities.include?(curation_concern.fileset_accessibility.first) && (!unrestrictable_doi_visibilities.include?(selected_visibility))
          curation_concern.errors.add(:base, "Media has been assigned a DOI and published. Visibility can only be changed to one of: #{unrestrictable_doi_visibilities.join(', ')}")
        else
          public = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
          private = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
          embargo = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO
          lease = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_LEASE

          case selected_visibility
          when public
            map_fileset_accessibility("","open")
          when "restricted_download"
            map_work_visibility(public)
            map_fileset_accessibility("","restricted_download")
          when "preview"
            map_work_visibility(public)
            map_fileset_accessibility("","preview_only")
          when "hidden"
            map_work_visibility(public)
            map_fileset_accessibility("restricted","hidden")
          when private
            map_fileset_accessibility("","private")
          when embargo
            map_fileset_accessibility("","")
          when lease
            map_fileset_accessibility("","")
          end
          update_fileset_accessibility
        end
      end

      def update_fileset_accessibility
        curation_concern.file_sets.each do |file|
          file.accessibility = curation_concern.fileset_accessibility
          file.save!
        end
      end

      # Sets work's fileset_visibility and fileset_accessibility values depending on publication status
      def map_fileset_accessibility(visibility,accessibility)
        curation_concern.fileset_visibility = [visibility]
        curation_concern.fileset_accessibility = [accessibility]
      end

      # Maps work visibility to Hyrax value for non-Hyrax publication status
      def map_work_visibility(visibility)
        params["media"]["visibility"] = visibility
      end

      def after_update_response
        if browse_everything_file_present
          flash[:alert] = I18n.t("morphosource.media.alert.browse_everything")
        end
        if (fileset_visibility_changed? || curation_concern.visibility_changed?)
          if curation_concern.attributes["fileset_visibility"] == [""]
            if permissions_changed?
              return redirect_to hyrax.copy_access_permission_path(curation_concern), alert: flash[:alert]
            else
              return redirect_to main_app.copy_hyrax_permission_path(curation_concern), alert: flash[:alert]
            end
          end
          if curation_concern.attributes["fileset_visibility"] == ["restricted"]
            InheritPermissionsJob.perform_later(curation_concern.id) if permissions_changed?
            restrict_all_filesets
            flash_message = 'Updating file permissions to restricted. This may take a few minutes. You may want to refresh your browser or return to this record later to see the updated file permissions.'
            return redirect_to [main_app, curation_concern], notice: flash_message
          end
        end
        respond_to do |wants|
          wants.html { redirect_to [main_app, curation_concern], notice: "Work \"#{curation_concern}\" successfully updated." }
          wants.json { render :show, status: :ok, location: polymorphic_path([main_app, curation_concern]) }
        end
      end

      def browse_everything_file_present
        params[:selected_files].present? && params[:uploaded_files].present?
      end

      # get the old file set visibility so we can tell if it is being changed
      def save_fileset_visibility
        if curation_concern.fileset_visibility == [""]
          @saved_fileset_visibility = [""]
        else
          @saved_fileset_visibility = ["restricted"]
        end
      end

      def fileset_visibility_changed?
        @saved_fileset_visibility.first != curation_concern.fileset_visibility.first
      end

      def restrict_all_filesets
        curation_concern.file_sets.each do |file|
          file.embargo&.deactivate!
          file.lease&.deactivate!
          file.visibility = "restricted"
          file.save!
        end
        curation_concern.update_index
      end

      def update_thumbnail
        # delete custom thumbnail
        if params[:media][:delete_thumbnail] == "1"
          delete_thumbnail
        end
        # add custom thumbnail
        if params[:custom_thumbnail].present?
          create_thumbnail
        end
      end

      def set_fund_code
        if current_user.admin?
          if params[:media][:select_fund_code].present?
            activate_fund_code
          end

          if params[:media][:select_new_fund_code].present?
            set_new_fund_code(params[:media][:select_new_fund_code])
          end
        end
      end

      def activate_fund_code
        return nil if !params[:media][:select_fund_code].present?
        if FundCodeMediaAssociation.exists?(params[:media][:select_fund_code])
          fcma = FundCodeMediaAssociation.find(params[:media][:select_fund_code])
          if fcma.media == media.id
            fcma.update(active: true)
          end
        end
      end

      def set_new_fund_code(fc_id = nil)
        return nil if !fc_id.present?
        if FundCode.exists?(fc_id)
          fc = FundCode.find(fc_id)
          media.new_fund_code_association(fc)
        end
      end

      def validate_individual_access
        if params["media"]["permissions_attributes"].present?
          non_contributors = []
          params["media"]["permissions_attributes"].each do |k, v|
            if v[:type] == "person" && v[:access] == "edit"
              if v[:name].present?
                user = ::User.find_by_user_key(v[:name])
              elsif v[:agent_name].present?
                user = ::User.find_by_user_key(v[:agent_name])
              end
              if user.present?
                unless user.contributor?
                  params["media"]["permissions_attributes"].delete(k)
                  non_contributors << user.name_or_email
                end
              else
                params["media"]["permissions_attributes"].delete(k)
                flash[:error] = "Sorry, there is an issue finding the user."
              end
            end
          end
          if non_contributors.present?
            flash[:error] = "Sorry, access cannot be given to users who are not contributors: " + non_contributors.join(", ")
          end
        end
      end

      def save_individual_access
        @saved_edit_users = curation_concern.edit_users
        @saved_read_users = curation_concern.read_users
        @saved_download_users = curation_concern.download_users
      end

      def deliver_individual_access_messages
        media_link = "<b><a href='http://#{host_name}/media/#{curation_concern.id}'>Media #{curation_concern.id}: #{curation_concern.title.first}</a></b>"
        contact_message = "<p>Please contact #{user_email_link([current_user])} if you have a question related to this media access settings.</p>"

        unless curation_concern.edit_users.sort == @saved_edit_users.sort
          # find new EDIT access user(s)
          new_edit_users = curation_concern.edit_users - @saved_edit_users
          new_edit_users.each do |user_key|
            message = "You now have edit access to #{media_link}." + contact_message
            receiving_user = ::User.find_by_user_key(user_key)
            deliver_message(email_sender, receiving_user, message.html_safe, "You have been given edit access to a media")
          end
          # find EDIT access user(s) removed
          removed_edit_users = @saved_edit_users - curation_concern.edit_users
          removed_edit_users.each do |user_key|
            message = "Your edit access to #{media_link} has been removed." + contact_message
            receiving_user = ::User.find_by_user_key(user_key)
            deliver_message(email_sender, receiving_user, message.html_safe, "Your edit access to a media has been removed")
          end
        end

        unless curation_concern.download_users.sort == @saved_download_users.sort
          # find new DOWNLOAD access user(s)
          new_download_users = curation_concern.download_users - @saved_download_users
          new_download_users.each do |user_key|
            message = "You now have download access to #{media_link}." + contact_message
            receiving_user = ::User.find_by_user_key(user_key)
            deliver_message(email_sender, receiving_user, message.html_safe, "You have been given download access to a media")
          end
          # find DOWNLOAD access user(s) removed
          removed_download_users = @saved_download_users - curation_concern.download_users
          removed_download_users.each do |user_key|
            message = "Your download access to #{media_link} has been removed." + contact_message
            receiving_user = ::User.find_by_user_key(user_key)
            deliver_message(email_sender, receiving_user, message.html_safe, "Your download access to a media has been removed")
          end
        end

        unless curation_concern.read_users.sort == @saved_read_users.sort
          # find new READ access user(s)
          new_read_users = curation_concern.read_users - @saved_read_users
          new_read_users.each do |user_key|
            message = "You now have view access to #{media_link}." + contact_message
            receiving_user = ::User.find_by_user_key(user_key)
            deliver_message(email_sender, receiving_user, message.html_safe, "You have been given view access to a media")
          end
          # find READ access user(s) removed
          removed_read_users = @saved_read_users - curation_concern.read_users
          removed_read_users.each do |user_key|
            message = "Your view access to #{media_link} has been removed." + contact_message
            receiving_user = ::User.find_by_user_key(user_key)
            deliver_message(email_sender, receiving_user, message.html_safe, "Your view access to a media has been removed")
          end
        end

      end

  end
end
