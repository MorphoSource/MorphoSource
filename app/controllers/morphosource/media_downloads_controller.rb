require 'axlsx'

# DrainableIO and RemoteInclusion help smooth out IntervalResponse and ZipTricks functionality
class DrainableIO < StringIO
  def to_segment_and_clear
    string.dup.tap do
      truncate(0)
      rewind
    end
  end
end

RemoteInclusion = Struct.new(:url, :bytesize)

module Morphosource
  class MediaDownloadsController < ApplicationController
    include Morphosource::CartItems

    # Access-control keys are always UUIDs. Used to validate keys before interpolating
    # them into Solr fq strings, guarding against query injection via params[:key].
    ACCESS_KEY_PATTERN = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-5][0-9a-f]{3}-[089ab][0-9a-f]{3}-[0-9a-f]{12}\z/i

    before_action :validate_params, only: [:show]
    before_action :validate_download_hash, only: [:show]
    before_action :validate_user, only: [:show]
    after_action :reset_recaptcha, only: [:show]

    def show
      prepare_all_files
      if @files.present? && @all_files.present?
        create_or_update_cart_items_for_download
        create_interval_sequence
        send_interval_response
      else
        flash[:error] = "There is an issue with one of the media you have attempted to download, and it is not available right now. Please try again later. If the issue persists, contact us (morphosource@duke.edu)."
        redirect_to request.referer.present? ? request.referer : '/' and return
      end
    end

    def prepare_all_files
      if @is_download_from_api
        # there is only one media to prepare if download from api
        @media = [@media]
      end
      @temp_files = []
      @all_files ||= files + standard_agreement_files + media_agreement_files + xlsx_manifest + csv_manifest + unavailable_media_notice_file
    end

    # Media ids skipped by prepare_files because their file could not be validated.
    # Populated as a side effect of calling `files`/`prepare_files`.
    def unavailable_media_ids
      @unavailable_media_ids ||= []
    end

    # Bundles a plain-text notice into the zip itself when some media were skipped, so the
    # message is visible the moment the user opens the download - no reliance on a flash
    # message surfacing on some later page load.
    def unavailable_media_notice_file
      return [] unless unavailable_media_ids.present?

      file_name = "unavailable_items.txt"
      file_path = File.join(temp_manifest_directory, "#{SecureRandom.uuid}-#{file_name}")
      File.write(file_path, unavailable_media_notice_text)
      file = File.open(file_path)
      crc32 = crc32_from_io(file)
      [{
        name: file_name,
        size: file.size,
        crc32: crc32,
        file: file
      }]
    end

    def unavailable_media_notice_text
      "The following item(s) could not be downloaded because a file is currently unavailable:\n\n" \
      "#{unavailable_media_ids.join("\n")}\n\n" \
      "They remain in your cart untouched. Please try again later, or remove them if the issue persists.\n" \
      "If it continues, contact us (morphosource@duke.edu)."
    end

    def create_or_update_cart_items_for_download
      media.each do |m|
        next if unavailable_media_ids.include?(m.id)

        if (item = find_downloaded_downloadable_item(m.id, download_hash)).present?
          # CartItem for media with DL hash exists, can increment DL attempts and update DL date
          add_subsequent_download(item, "UI")
        elsif (item = find_undownloaded_approved_request_item(m.id)).present?
          # Undownloaded approved request exists, associate download with request
          add_first_download(item, download_hash)
        elsif (item = find_undownloaded_downloadable_item(m.id)).present?
          # Undownloaded downloadable item exists (e.g., in media cart), associated download
          add_first_download(item, download_hash)
        else
          # Add new CartItem for download
          create_downloaded_item(m.id, download_hash)
        end
      end
    end

    def create_interval_sequence
      io = DrainableIO.new
      zip = ZipTricks::Streamer.new(io)
      @all_files.each do |file|
        next unless file[:file].present?

        # raw_file is written "as is" (STORED mode).
        # Write the local file header first..
        zip.add_stored_entry(filename: file[:name], size: file[:size], crc32: file[:crc32])

        # local zip file header
        interval_sequence << io.to_segment_and_clear

        # file data
        if file[:file].is_a?(File) || file[:file].is_a?(Tempfile)
          interval_sequence << IntervalResponse::LazyFile.new(file[:file])
        else # must be streamable
          interval_sequence << file[:file]
        end

        # Adjust the ZIP offsets within the Streamer
        zip.simulate_write(file[:size])
      end
      zip.close
      # zip central directory header
      interval_sequence << io.to_segment_and_clear
    end

    def send_interval_response
      zipname = zip_name
      interval_response = IntervalResponse.new(interval_sequence, request.env)
      rack_response = interval_response.to_rack_response_triplet
      self.status = rack_response[0]
      self.response.headers.merge!(rack_response[1])
      self.response_body = IntervalResponse::RemoteRackBodyWrapper.new(
        interval_response,
        chunk_size: IntervalResponse::RackBodyWrapper::CHUNK_SIZE
      )
      headers['Content-Disposition'] = "attachment; filename=\"#{zipname.gsub '"', '\"'}\""
      headers['Content-Type'] = Mime::Type.lookup_by_extension('zip').to_s
      response.sending_file = true
      response.cache_control[:public] ||= false
    end

    def zip_name
      # Reflect what's actually in the zip, not what was originally requested -
      # unavailable media are skipped by prepare_files and never make it in.
      included_media = media.reject { |m| unavailable_media_ids.include?(m.id) }

      m = ""
      if included_media.present? && ( included_media.count == 1 )
        m = "id-#{included_media&.first&.id}"
      elsif included_media.present? && ( included_media.count > 1 )
        m = if included_media.count == media.count
              "#{included_media.count}-items"
            else
              "#{included_media.count}-of-#{media.count}-items"
            end
      end

      "morphosource_media-#{m}_download-#{download_hash[0..7]}.zip"
    end

    private
      # Validation methods

      def validate_params
        return head(:bad_request) unless params_valid?
      end

      def params_valid?
        user_from_token.present? && media.present? && download_hash.present?
      end

      # Get user record from token param
      def user_from_token
        @user ||= User.where(token: params[:token])&.first if params[:token].present?
      end

      # Get Media from keys
      def media
        @media ||= if keys.empty?
          []
        else
          docs = ActiveFedora::SolrService.query(
            "*:*",
            fq: ["has_model_ssim:Media", "{!terms f=accessControl_ssim}#{keys.join(',')}"],
            rows: keys.uniq.length,
            fl: ['id'],
            method: :post
          )
          ids = docs.map { |d| d['id'] }
          ids.empty? ? [] : Media.find(ids)
        end
      end

      # Session-stored keys are used for batch cart downloads (avoids oversized redirect URLs).
      # Direct key[] params are used by the single-media download modal and controller specs.
      def keys
        entry = session.dig(:download_keys, params[:download])
        raw = entry&.fetch("keys", nil) || Array(params[:key])
        @keys ||= raw.select { |k| k.to_s.match?(ACCESS_KEY_PATTERN) }
      end

      def download_hash
        @download_hash ||= params[:download] if params[:download].present?
      end

      def validate_download_hash
        return head(:bad_request) unless ACCESS_KEY_PATTERN.match?(download_hash.to_s)
      end

      def validate_user
        return head(:unauthorized) unless user_is_valid?
      end

      def user_is_valid?
        user_from_token.present? && current_user == user_from_token && authorized_to_download?
      end

      def authorized_to_download?
        media.all? { |m| user_can_download? user_from_token, m }
      end

      def user_can_download?(user, media)
        user.active && ( user.can?(:download, media.id) || user.approved_to_download?(media.id) )
      end

      def reset_recaptcha
        # this controller doesn't interact with recaptcha (yet!) but this is left in, just in case
        session.delete(:recaptcha_verfied_in_cart)
      end

      # Controller HTTP response methods

      def interval_sequence
        @interval_sequence ||= IntervalResponse::Sequence.new
      end

      # Methods for preparing media binary files

      def files
        @files ||= prepare_files
      end

      def prepare_files
        media.map do |m|
          if m.is_remote_backed?
            file_set = get_and_validate_fileset_for_remote(m)
            unless file_set.present?
              unavailable_media_ids << m.id
              next nil
            end
            file_uri = file_set.import_url
          else
            file_set, original_file = get_and_validate_fileset(m)
            unless file_set.present? && original_file.present?
              unavailable_media_ids << m.id
              next nil
            end
            file_uri = file_set.original_file.uri
          end

          attrs = {
            name: File.join(
              output_dirname(m),
              output_filename(file_set, m.id)
            ),
            size: file_set.file_size&.first.to_i,
            crc32: file_set.crc32&.first.to_i,
            file: RemoteInclusion.new(file_uri, file_set.file_size&.first.to_i)
          }

          if attrs.values.all? { |v| v.present? }
            attrs
          else
            unavailable_media_ids << m.id
            nil
          end
        end.compact
      end

      def get_and_validate_fileset_for_remote(m)
        if (
          (file_set = m.file_sets&.first).present? &&
          file_set.file_size&.first.present? &&
          file_set.crc32&.first.present? &&
          file_set.original_file.uri.present? &&
          file_set.original_file.original_name.present?
        )
          return file_set
        else
          return nil
        end
      end

      def get_and_validate_fileset(m)
        if (
          (file_set = m.file_sets&.first).present? &&
          (original_file = file_set.original_file).present? &&
          file_set.file_size&.first.present? &&
          file_set.crc32&.first.present? &&
          original_file.original_name.present? &&
          original_file.uri.present?
        )
          return file_set, original_file
        else
          return nil, nil
        end
      end

      # Get FileSets from Media
      def file_sets
        @file_sets ||= media.map(&:file_sets).flatten.compact
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
          if m.morphosource_use_agreement_type&.first == 'Permissive'
            { type: 'permissive' }
          else
            {
              type: 'std',
              permits_commercial_use:
                permits_commercial_use(
                  m.permits_commercial_use&.first
                ),
              required_archival_of_published_derivatives:
                required_archival_of_published_derivatives(
                  m.required_archival_of_published_derivatives&.first
                ),
              permits_3d_use: permits_3d_use(
                  m.permits_3d_use&.first
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
            name: media_agreement_file_name(file_hash[:path], index + 1)
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

      # Methods for creating the CSV and XLSX media manifest file

      def temp_manifest_directory
        @temp_manifest_directory ||= begin
          directory_name = Dir.tmpdir() + "/download-media-manifest"
          Dir.mkdir(directory_name) unless File.exist?(directory_name)
          directory_name
        end
      end

      def manifest_filename
        "media-manifest-#{SecureRandom.uuid}"
      end

      def csv_manifest
        file_name = "#{manifest_filename}.csv"
        csv_path = File.join(temp_manifest_directory, file_name)
        CSV.open(csv_path, "wb") do |csv|
          csv << manifest_headers
          media_hashes.each do |h|
            csv << h.values.map{ |v| v.first }
          end
        end
        file = File.open(csv_path)
        crc32 = crc32_from_io(file)
        [{
          name: file_name,
          size: file.size,
          crc32: crc32,
          file: file
        }]
      end

      def xlsx_manifest
        file_name = "#{manifest_filename}.xlsx"
        xlsx_path = File.join(temp_manifest_directory, file_name)

        p = Axlsx::Package.new
        wb = p.workbook
        date_time_format = wb.styles.add_style :format_code => 'YYYY-MM-DD'
        manifest_headers = media_hashes.first.keys.flatten.map{ |s| s.to_s }
        wb.add_worksheet(:name => "xlsx manifest") do |sheet|
          sheet.add_row manifest_headers
          media_hashes.each do |h|
            sheet.add_row h.values.map{ |v| v.first },
              :types => xlsx_column_types(manifest_headers),
              :style => xlsx_column_styles(manifest_headers, date_time_format)
          end
        end
        p.serialize xlsx_path

        file = File.open(xlsx_path)
        crc32 = crc32_from_io(file)
        [{
          name: file_name,
          size: file.size,
          crc32: crc32,
          file: file
        }]
      end

      def xlsx_column_types(headers)
        types = []
        headers.each do |header|
          case header
          when 'date_uploaded', 'date_modified'
            types << nil
          else
            types << :string
          end
        end
        return types
      end

      def xlsx_column_styles(headers, date_time_format)
        styles = []
        headers.each do |header|
          case header
          when 'date_uploaded', 'date_modified'
            styles << date_time_format
          else
            styles << nil
          end
        end
        return styles
      end

      def manifest_headers
        @manifest_headers ||= media_hashes.first.keys.flatten.map{ |s| s.to_s }
      end

      def media_hashes
        @media_hashes ||= begin
          media_list = []
          media.each do |m|
            doc = SolrDocument.find(m.id)
            if doc.present?
              if m.is_remote_backed?
                file_set = get_and_validate_fileset_for_remote(m)
              else
                file_set, original_file = get_and_validate_fileset(m)
              end
              if file_set.present?
                media_list << {
                  :id => [m.id],
                  :title => [m.title.first],
                  :file_name => [file_set.label],
                  :file_size => file_set.file_size,
                  :media_type => m.media_type,
                  :mime_type => [m.is_remote_backed? ? file_set.mime_type_of_remote : file_set.mime_type]
                }.merge(doc.to_semantic_values).merge({
                  :points => file_set.point_count,
                  :polygons => file_set.face_count,
                  :vertex_color => file_set.vertex_color,
                  :uv_coordinates => file_set.has_uv_space,
                  :bounding_box_x => file_set.bounding_box_x,
                  :bounding_box_y => file_set.bounding_box_y,
                  :bounding_box_z => file_set.bounding_box_z,
                  :status => ['Included']
                })
              else
                media_list << {
                  :id => [m.id],
                  :title => [m.title.first],
                  :media_type => m.media_type,
                  :status => ['Not included - file unavailable']
                }
              end
            end
          end
          media_list
        end
      end

      def crc32_from_io(file)
        crc = ZipTricks::StreamCRC32.from_io(file)
        file.rewind
        return crc
      end

      # other zip methods
      def output_dirname(media)
        "Media #{media.id} - #{media.title.join('-').tr('[]:','').tr('/\\','-')}"
      end

      def output_filename(file_set, media_id)
        file_name = file_set.original_file.original_name
        if file_set.is_remote_backed? && !File.extname(file_name).present?
          file_name = file_set.label || ""
        end
        File.basename(file_name, File.extname(file_name)) + "-#{media_id}" + File.extname(file_name)
      end
  end
end