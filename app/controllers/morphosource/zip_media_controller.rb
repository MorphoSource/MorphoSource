module Morphosource
  class ZipMediaController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Morphosource::CartItems

    include ActionController::Streaming
    include Zipline
    require 'open-uri'

    # GET /zip?ids[]=filesetid1&ids[]=filesetid2
    def zip
      return head(:bad_request) unless zip_params_valid?
      return head(:unauthorized) unless authorized_to_download?
      prepare_file_paths_and_names
      return head(:bad_request) if @files.length == 0
      create_downloaded_cart_items
      prepare_files_to_zip
      zipline(@file_mappings, "#{output_prefix}.zip")
    end

    private

      def zip_params_valid?
        params[:ids] && params[:ids].is_a?(Array) && params[:ids].any?
      end

      def authorized_to_download?
        @media_ids = params[:ids].uniq
        @media_ids.each do |id|
          # next if user has download access to media
          next if current_user.can?(:download, id)
          # next if user has an approved request to download
          next if current_user.approved_to_download?(id)
          return false
        end
        true
      end

      def prepare_file_paths_and_names
        media = ::Media.where(id: params[:ids])
        file_sets = media.map{|m| m.file_sets}.flatten
        @files = file_sets.map do |file|
          m = file.parent
          [file.original_file.uri.to_s, "#{output_prefix}/#{output_dirname(m)}/#{output_filename(file)}", modification_time: file.date_modified]
        end
      end

      def output_prefix
        @output_prefix ||= "morphosource-#{Time.now.strftime("%Y-%m-%d-%H%M%S")}"
      end

      def output_dirname(m)
        "#{m.title.join('-').tr('[]:','').tr('/\\','-')}-#{m.id}"
      end

      def output_filename(file)
        File.basename(file.label, File.extname(file.label)) + "-#{file.id}" + File.extname(file.label)
      end

      def create_downloaded_cart_items
        @media_ids.each do |id|
          if downloadable_item_for_work?(id)
            item = find_downloadable_item(id)
            if item.date_downloaded
              create_downloaded_item(id)
            else
              mark_as('downloaded',item)
            end
          else
            create_downloaded_item(id)
          end
        end
      end

      def prepare_files_to_zip
        add_aups_to_file_list
        add_media_usage_agreements_to_file_list
        prepare_file_mappings
      end

      def media_permissions_string(media_id)
        if media_id.present?
          media = ::Media.find(media_id)
          permissions_string = ''
          if media.morphosource_use_agreement_type == ['Permissive']
            permissions_string = 'permissive'
          else
            permissions_string += 'std_'
            if media.permits_commercial_use == ['CommercialUsePermitted']
              permissions_string += 'comm_yes_'
            else
              permissions_string += 'comm_no_'
            end
            if media.required_archival_of_published_derivatives == ['OnAnyRepository']
              permissions_string += 'rearc_any_'
            elsif media.required_archival_of_published_derivatives == ['OnMorphoSource']
              permissions_string += 'rearc_ms_'
            else
              permissions_string += 'rearc_no_'
            end
            if media.permits_3d_use == ['3DPrintingPermitted']
              permissions_string += '3d_yes'
            elsif media.permits_3d_use == ['3DPrintingLimited']
              permissions_string += '3d_limited'
            else
              permissions_string += '3d_no'
            end
          end
          return permissions_string
        end
      end

      def aup_filenames
        @media_ids.
          map { |id| media_permissions_string(id) }.
          compact.
          uniq.
          map { |permission| "ms_usage_#{permission}.pdf" }
      end

      def aup_paths
        aup_filenames.map do |aup_filename|
          File.join(Rails.root, %w{app assets documents}, aup_filename)
        end
      end

      def add_aups_to_file_list
        aup_paths.each do |aup_path|
          @files.unshift([aup_path, "#{output_prefix}/#{File.basename(aup_path)}", modification_time: Time.now])
        end
      end

      def add_media_usage_agreements_to_file_list
        @files.unshift(*media_usage_agreements)
      end

      def media_usage_agreements
        @media_ids.
          map { |id| Morphosource::AttachmentService.get(id, 'agreement') }.
          compact.
          uniq.
          map.with_index do |item, index|
            [item, "#{output_prefix}/#{agreement_filename(item, index + 1)}", modification_time: Time.now]
          end
      end

      def agreement_filename(item, idx)
        "Media_Contributor_Usage_Agreement_#{idx}#{File.extname(item).downcase}"
      end

      def prepare_file_mappings
        @file_mappings = @files.lazy.map{|url,path,options| [open(url), path, options]}
      end
  end
end
