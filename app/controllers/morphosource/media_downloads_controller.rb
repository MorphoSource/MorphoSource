module Morphosource
  class MediaDownloadsController < ApplicationController

    def show
      # create_downloaded_cart_items # todo
      # need to validate can user download all media?
      prepare_all_files
      create_response
    end

    def prepare_all_files
      @all_files ||= files.merge(standard_agreement_files).merge(media_agreement_files)
    end

    private
      # Methods for accessing works or other documents

      # Media access_control keys
      def keys 
        @keys ||= Array(params[:key])
      end

      # Get Media from keys
      def media
        @media ||= Media.where(accessControl_ssim: @keys)
      end

      # Get FileSets from Media
      def file_sets
        @file_sets ||= media.map(&:file_sets).flatten.compact
      end

      # Get Hydra::PCDM::File original_files from FileSets
      def original_files
        @original_files ||= file_sets.map(&:original_file).compact
      end

      # Methods for preparing media binary files

      def files
        @files ||= prepare_files
      end

      def prepare_files
        original_files.map do |original_file|
          attrs = {
            name: original_file.original_name,
            size: original_file.file_size&.first.to_i,
            crc32: original_file.crc32&.first.to_i,
            file: original_file.stream
          }

          if attrs.values.all? { |v| v.present? }
            attrs
          else
            nil
          end
        end.compact
      end

      # Media-specific custom agreement file methods

      def media_agreement_files
        crcs = []
        media_agreement_file_paths.map do |file_path, file_name|
          file = File.open(file_path)
          crc32 = crc32_from_io(file)

          if crcs.include?(crc32)
            nil
          else
            {
              size: file.size,
              crc32: crc32,
              file: file,
              path: file_path
            }
          end
        end.
        compact.
        uniq.
        map.with_index do |file_hash, index|
          file_hash.merge(
            name: media_agreement_file_name(file_hash[:file_path], index + 1)
          )
        end
      end

      def media_agreement_file_paths
        media.
          map { |m| Morphosource::AttachmentService.get(m.id, 'agreement') }.
          compact.
          uniq
      end

      def media_agreement_file_name(file_path, index)
        "Media_Contributor_Usage_Agreement_#{index}#{File.extname(file_path).downcase}"
      end

      # MorphoSource standard agreement file methods

      def standard_agreement_files
        standard_agreement_file_names.map do |file_name|
          file = File.open(standard_agreement_file_path(file_name))

          {
            name: file_name,
            size: file.size,
            crc32: crc32_from_io(file),
            file: file
          }
        end
      end

      def standard_agreement_file_names
        standard_agreement_settings.map do |s|
          if s[:type] == 'permissive'
            label = s[:type]
          else
            label = [
              s[:type], 
              s[:permits_commercial_use], 
              s[:required_archival_of_published_derivatives], 
              s[:permits_3d_use]
            ].join('_')
          end

          standard_agreement_file_name(label)
        end
      end

      def standard_agreement_settings
        media.map do |m|
          if media.morphosource_use_agreement_type&.first == 'Permissive'
            { type: 'permissive' }
          else
            {
              type: 'std',
              permits_commercial_use: 
                permits_commercial_use(
                  media.permits_commercial_use&.first
                ),
              required_archival_of_published_derivatives: 
                required_archival_of_published_derivatives(
                  media.required_archival_of_published_derivatives&.first
                ),
              permits_3d_use: permits_3d_use(
                  media.permits_3d_use&.first
                )
            }
          end
        end.uniq
      end

      def permits_commercial_use(val)
        case val
        when 'CommercialUsePermitted'
          'comm_yes'
        else
          'comm_no'
        end
      end

      def required_archival_of_published_derivatives(val)
        case val
        when 'OnAnyRepository'
          'rearc_any'
        when 'OnMorphoSource'
          'rearc_ms'
        else
          'rearc_no'
        end
      end

      def permits_3d_use(val)
        case val
        when '3DPrintingPermitted'
          '3d_yes'
        when '3DPrintingLimited'
          '3d_limited'
        else
          '3d_no'
        end
      end

      def standard_agreement_file_name(permissions_label)
        "ms_usage_#{permissions_label}.pdf"
      end

      def standard_agreement_file_path(file_name)
        File.join(Rails.root, %w{app assets documents}, file_name)
      end

      def crc32_from_io(file)
        crc = ZipTricks::StreamCRC32.from_io(file)
        file.rewind
        return crc
      end  
  end
end