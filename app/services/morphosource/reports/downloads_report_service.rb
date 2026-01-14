module Morphosource
  module Reports
    class DownloadsReportService < CartItemsReportService
      self.where_chain += [:where_downloaded]

      def where_downloaded(model_or_result)
        model_or_result.where.not(date_downloaded: nil)
      end

      def attributes
				[:work_id, :date_downloaded, :download_usage, :download_usage_list, :user_id]
			end

      # Adds media attributes to the download data for the report
      # The order of the attributes here determines the order in the CSV export
      def media_attributes
        %w(title_tesim
           part_tesim
           modality_ssim
           media_type_tesim
           physical_object_id_ssim
           physical_object_title_ssim
           institution_code_ssim
           collection_code_ssim
           catalog_number_ssim
           taxonomy_ssim)
      end

      def transform_download_data_for_report(download)
        media = SolrDocument.find(download['work_id'])
        # Regex to remove suffixes like _tesim, _ssim from field names for export; return a hash
        media = (media_attributes).to_h { |field| [field.sub(/_[a-zA-Z]+$/, ''), media[field]] }
        media_values = transform_for_report(media)
        # Add download_user_id to keep in the report - user_id will get transformed to user name/email
        download_values = transform_for_report(download.merge({"download_user_id" => download["user_id"]}))
        download_values.merge(media_values)
      end

      def format_results
        results_for_format = attributes.present? ? results.select(attributes) : results
        results_for_format.map do |cart_item|
          transformed_item = transform_download_data_for_report(cart_item.attributes.except('id'))
        end
      end
    end
  end
end