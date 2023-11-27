module Morphosource
  # Methods for CSV and JSON API exports of collection contents
  module CollectionsControllerExportBehavior
    extend ActiveSupport::Concern
    include Morphosource::RestApiBehavior

    included do
      before_action :authenticate_api_key_optional, only: [
        :media_export, :objects_export, :media_download_counts, :media_downloads, :media_requests
      ]
    end

    def export_render(csv_response_header=nil)
      respond_to do |format|
        format.json do
          if @response.present?
            @presenter = Morphosource::JsonPresenter.new(
              @response,
              @document_list,
              facets_from_request.reject { |f| f.name == "generic_type_sim" },
              blacklight_config
            )
          else
            @render_only_document_list = true
          end
          render 'show'
        end
        format.csv do
          csv_response_headers(csv_response_header)
          render 'show'
        end
      end
    end

    ### Works Export ###

    def objects_export
      @document_type = 'object'
      works_export
    end

    def media_export
      @document_type = 'media'
      works_export
    end

    def devices_export
      @document_type = 'device'
      works_export
    end

    def works_export
      deny_access_unauthorized and return unless current_user.present?
      deny_access_forbidden    and return unless current_user.can?(:edit, @collection)

      if request.format == 'csv'
        repository.blacklight_config.max_per_page = 9999999
      end
      (@response, @document_list) = query_solr_all_results
      @document_list.map! { |d| d.to_semantic_values }
      export_render(works_export_filename)
    end

    ### Download and Download Request Export ###

    def media_downloads
      deny_access_unauthorized and return unless current_user.present?
      deny_access_forbidden    and return unless current_user.can?(:edit, @collection)

      @document_type = 'media_download'
      repository.blacklight_config.max_per_page = 9999999
      (_, @media_document_list) = query_solr_all_results
      media_ids = @media_document_list.map{|d| d["id"]}.flatten.compact.uniq
      @document_list = Morphosource::Reports::DownloadsReportService.call(media_ids)
      export_render(media_downloads_filename)
    end

    def media_download_counts
      deny_access_unauthorized and return unless current_user.present?
      deny_access_forbidden    and return unless current_user.can?(:edit, @collection)

      @document_type = 'media_with_download_count'
      if request.format == 'csv'
        repository.blacklight_config.max_per_page = 9999999
      end
      (@response, @media_document_list) = query_solr_all_results
      media_ids = @media_document_list.map{|d| d["id"]}.flatten.compact.uniq
      downloads = Morphosource::Reports::DownloadsReportService.call(media_ids)

      user_demographics = downloads.pluck('download_user_id').uniq.map do |user_id|
        [user_id, User.find_by_user_key(user_id)&.demographics ]
      end.to_h

      download_counts_by_media = downloads.group_by{|h| h['media_id'] }.map do |media_id, dls|
        [ media_id, download_counts_hash(dls, user_demographics, request.format) ]
      end.to_h

      @document_list = @media_document_list.map do |doc|
        dl_counts = download_counts_by_media[doc['id']] || download_counts_hash([], [], request.format)
        doc_semantic = doc.to_semantic_values

        if request.format == 'csv'
          doc_semantic.merge(dl_counts)
        else
          { id: doc_semantic[:id], title: doc_semantic[:title], media: doc_semantic }.merge(dl_counts)
        end
      end
      export_render(media_download_counts_filename)
    end

    def media_requests
      deny_access_unauthorized and return unless current_user.present?
      deny_access_forbidden    and return unless current_user.can?(:edit, @collection)

      @document_type = 'media_request'
      repository.blacklight_config.max_per_page = 9999999
      (_, @media_document_list) = query_solr_all_results
      media_ids = @media_document_list.map{|d| d["id"]}.flatten.compact.uniq
      @document_list = Morphosource::Reports::RequestsReportService.call(media_ids)

      export_render(media_requests_filename)
    end

    private

    def download_counts_hash(downloads, user_demographics, format)
      use_intent_categories, demographic_categories = download_categories(downloads, user_demographics)
      addl_fields = {}

      if format == 'csv'
        addl_fields.merge!(
          { 'unique_download_user_use_intent_counts' => nil },
          use_intent_categories,
          { 'unique_download_user_demographic_counts' => nil },
          demographic_categories
        )
      else
        addl_fields.merge!(
          'unique_download_user_use_intent_counts' => use_intent_categories,
          'unique_download_user_demographic_counts' => demographic_categories
        )
      end

      {
        downloads: downloads.length,
        unique_download_users: downloads.pluck('download_user_id').uniq.compact.count,
      }.merge(
        addl_fields
      )
    end

    def download_categories(downloads, user_demographics)
      use_intent_categories = empty_use_intent_categories.deep_dup
      demographic_categories = empty_demographic_categories.deep_dup

      downloads_by_user = downloads.group_by{|h| h['download_user_id'] }
      downloads_by_user.map do |user_id, user_downloads|
        # download usage intents
        use_intents = user_downloads.pluck('download_usage_list').map { |x| x&.split(';') }.flatten.uniq.compact
        use_intents.each { |cat| use_intent_categories[cat] += 1 if use_intent_categories.key?(cat) }
        # user demographics
        demographics = user_demographics[user_id]
        demographics.each { |cat| demographic_categories[cat] += 1 if demographic_categories.key?(cat) } if demographics.present?
      end

      [use_intent_categories, demographic_categories]
    end

    def empty_use_intent_categories
      @empty_use_intent_categories ||= Morphosource::UserProfile::CheckboxValues::INTENT.map { |term| [term, 0] }.to_h
    end

    def empty_demographic_categories
      @empty_demographic_categories ||= Morphosource::UserProfile::CheckboxValues::DEMOGRAPHICS.map { |term| [term, 0] }.to_h
    end

    def csv_response_headers(file_name)
      response.headers['Content-Type'] = 'text/csv'
      response.headers['Content-Disposition'] = "attachment; filename=MorphoSource%20#{collection.human_readable_type}%20#{@collection.id}%20-%20#{file_name}.csv"
    end

    def works_export_filename
      begin
        t("morphosource.collections.#{collection_type.title.downcase}.exports.#{tab.to_s}.media_export.filename")
      rescue
        "#{@document_type.titleize.pluralize} Query"
      end
    end

    def media_download_counts_filename
      begin
        t("morphosource.collections.#{collection_type.title.downcase}.exports.#{tab.to_s}.media_download_counts.filename")
      rescue
        'Media%20Download%20Counts'
      end
    end

    def media_downloads_filename
      begin
        t("morphosource.collections.#{collection_type.title.downcase}.exports.#{tab.to_s}.media_downloads.filename")
      rescue
        'Media%20Downloads'
      end
    end

    def media_requests_filename
      begin
        t("morphosource.collections.#{collection_type.title.downcase}.exports.#{tab.to_s}.media_requests.filename")
      rescue
        'Media%20Requests'
      end
    end
  end
end
