# Generated via
#  `rails generate hyrax:work Media`
module Hyrax
  # Generated controller for Media
  class MediaController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Hyrax::ChildWorkRedirect
    self.curation_concern_type = ::Media

    include ActionController::Streaming
    include Zipline
    require 'open-uri'

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::MediaPresenter

    before_action :save_fileset_visibility, only: [:update]
    before_action :save_publication_status, only: [:update]
    before_action :set_fileset_visibility, only: [:create, :update]
    skip_load_and_authorize_resource only: [:zip]

    # override the layout from WorksControllerBehavior
    def decide_layout
      layout = case action_name
               when 'show'
                 '1_column'
               when 'showcase'
                 'morphosource_2_columns'
               when 'edit'
                 'morphosource_2_columns'
               when 'update'
                 'morphosource_2_columns'
               else
                 'dashboard'
               end
      File.join(theme, layout)
    end

    def showcase
      @presenter = show_presenter.new(curation_concern_from_search_results, current_ability, request)
      @presenter.get_showcase_data
      render '/hyrax/media/showcase', presenter: @presenter
    end

    # overriding action methods from works_controller_behavior.rb
    def edit
      build_form
      @presenter = show_presenter.new(curation_concern_from_search_results, current_ability, request)
      @presenter.get_showcase_data

      if @presenter.imaging_event.present?
        ie_work = @presenter.imaging_event
        @imaging_event_form = Hyrax::WorkFormService.build(ie_work, current_ability, self)
      end

      if @presenter.processing_events.present?
        pe_work = @presenter.processing_events.first
        @processing_event_form = Hyrax::WorkFormService.build(pe_work, current_ability, self)
      end

      @new_organization_submit_submissions_url = '/submissions/new_organization_submit'
      @new_organization_form = Hyrax::WorkFormService.build(::Organization.new, current_ability, self)
      @countries_service = Morphosource::CountriesService.new
      render '/hyrax/media/edit', presenter: @presenter
    end



    # GET /concern/media/zip?ids[]=filesetid1&ids[]=filesetid2
    def zip
      if params[:ids] && params[:ids].is_a?(Array) && params[:ids].any?
        params[:ids].uniq!
        params[:ids].each{|i| authorize! :read, i} unless (Rails.env == 'test')
        output_prefix = "morphosource-#{Time.now.strftime("%Y-%m-%d-%H%M%S")}"
        files = ::Media.where(id: params[:ids]).map{|m| m.file_sets}.flatten.map do |f|
          authorize!(:read, f.id) unless (Rails.env == 'test')
          m = f.parent
          # Unzipped filename will be e.g. "Structured Light-2514nk481/bun_zipper_res2-nc580m649.ply"
          output_dirname = "#{m.title.join('-').tr('[]:','').tr('/\\','-')}-#{m.id}"
          output_filename = File.basename(f.label, File.extname(f.label)) + "-#{f.id}" + File.extname(f.label)
          [f.original_file.uri.to_s, "#{output_prefix}/#{output_dirname}/#{output_filename}", modification_time: f.date_modified]
        end
        if ((files.length == 0) && (Rails.env != 'test'))
          head :bad_request
        else
          aup_filename = 'MorphoSource_Download_Use_Agreement.pdf'
          aup_path = File.join(Rails.root, %w{app assets documents}, aup_filename)
          files.unshift([aup_path, "#{output_prefix}/#{aup_filename}", modification_time: Time.now])
          Rails.logger.debug("Files for zip: #{files.inspect}")
          # response.set_header('Content-Disposition', "attachment; filename=\"#{output_prefix}.zip\"")
          # response.set_header('Content-Type', Mime::Type.lookup_by_extension('zip').to_s)
          file_mappings = files.lazy.map{|url,path,options| [open(url), path, options]}
          zipline(file_mappings, "#{output_prefix}.zip")
        end
      end
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
      if file_formats_valid? && actor.update(actor_environment)
        update_cart_items if publication_status_changed?
        after_update_response
      else
        respond_to do |wants|
          wants.html do
            build_form
            #render 'edit', status: :unprocessable_entity
            # todo: make sure to handle error when changing media type
            @presenter = show_presenter.new(curation_concern_from_search_results, current_ability, request)
            @presenter.get_showcase_data


            @new_organization_submit_submissions_url = '/submissions/new_organization_submit'
            @new_organization_form = Hyrax::WorkFormService.build(::Organization.new, current_ability, self)
            @countries_service = Morphosource::CountriesService.new
            render '/hyrax/media/edit', presenter: @presenter, status: :unprocessable_entity

          end
          wants.json { render_json_response(response_type: :unprocessable_entity, options: { errors: curation_concern.errors }) }
        end
      end
    end

    private

      def manifest_builder
        ::IIIFManifest::V3::ManifestFactory.new(presenter)
      end

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
        end
        # Previous uploads
        self.curation_concern.file_sets.each do |file_set|
          if file_set.original_file.present?
            files << file_set.original_file.original_name
          # if a recent upload hasn't been processed yet, use the title instead.
          else
            files << file_set.title.first
          end
        end

        files.each do |file|
          invalid_files << file unless Morphosource::MEDIA_FORMATS[media_type][:extensions].include? File.extname(file)
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
        if (fileset_visibility_changed? || curation_concern.visibility_changed?)
          if curation_concern.attributes["fileset_visibility"] == [""]
            if permissions_changed?
              return redirect_to hyrax.copy_access_permission_path(curation_concern)
            else
              return redirect_to main_app.copy_hyrax_permission_path(curation_concern)
            end
          end
          if curation_concern.attributes["fileset_visibility"] == ["restricted"]
            InheritPermissionsJob.perform_later(curation_concern) if permissions_changed?
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

      # If publication status is updated, update all cart items for that work
      def save_publication_status
        @saved_publication_status = curation_concern.publication_status
      end

      def publication_status_changed?
        @saved_publication_status != curation_concern.publication_status
      end

      def update_cart_items
        items = CartItem.where(work_id: curation_concern.id)
        value = restrict_items?
        items.each do |item|
          item.restricted = value
          item.save
        end
      end

      def restrict_items?
        if curation_concern.active_lease?
          status = curation_concern.visibility_during_lease
        elsif curation_concern.under_embargo?
          status = curation_concern.visibility_during_embargo
        else
          status = curation_concern.publication_status
        end
        status != "open"
      end
  end
end
