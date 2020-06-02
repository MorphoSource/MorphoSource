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
          media = ::Media.find(id)
          # next if user has download access to media
          next if current_user.can? :download, id
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
        "morphosource-#{Time.now.strftime("%Y-%m-%d-%H%M%S")}"
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
        add_aup_to_file_list
        prepare_file_mappings
      end

      def aup_filename
        'MorphoSource_Download_Use_Agreement.pdf'
      end

      def aup_path
        File.join(Rails.root, %w{app assets documents}, aup_filename)
      end

      def add_aup_to_file_list
        @files.unshift([aup_path, "#{output_prefix}/#{aup_filename}", modification_time: Time.now])
      end

      def prepare_file_mappings
        @file_mappings = @files.lazy.map{|url,path,options| [open(url), path, options]}
      end
  end
end
