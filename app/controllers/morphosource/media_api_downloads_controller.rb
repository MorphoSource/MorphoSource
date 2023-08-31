module Morphosource
  class MediaAPIDownloadsController < MediaDownloadsController
    include Morphosource::RestApiBehavior

    skip_before_action :verify_authenticity_token, only: [:api_generate_download, :download]
    before_action :validate_when_download_from_api, only: [:download]
    before_action :validate_download_hash, only: [:download]

    before_action :authenticate_api_key_required, only: [:api_generate_download]
    before_action :validate_params_for_api_generate_download, only: [:api_generate_download]

    def download
      prepare_all_files
      if @files.present? && @all_files.present?
        add_subsequent_download(cart_item_for_download_from_api, "API")
        create_interval_sequence
        send_interval_response
      else
        return render_json_by_http_code 400, ["There is an issue with one of the media you have attempted to download, and it is not available right now. Please try again later. If the issue persists, contact us (morphosource@duke.edu)."]
      end
    end

    def use_statement
      @use_statement ||= request.params[:use_statement]&.strip
    end

    def use_categories
      @use_categories ||= request.params[:use_categories]
    end

    def use_categories_final
      @use_categories_final ||= [use_categories, use_category_other].compact.flatten.reject(&:empty?)
    end

    def use_category_other
      @use_category_other ||= request.params[:use_category_other]&.strip
    end

    def agreements_accepted?
      request.params[:agreements_accepted] == true
    end

    def api_generate_download
      @is_api_generate_download = true
      if create_or_update_cart_item_for_link_generation.nil?
        render_json_by_http_code 404
      else
        query_params = {
          key: media.access_control_id,
          download: download_hash,
          usage: use_statement,
          usage_list: use_categories_final.join(';')
        }
        download_url = url_for(controller: 'media_api_downloads', action: 'download', id: media.id, protocol: request.protocol, host: request.host_with_port, params: query_params)
        json_obj = {            
          "response": {
            "media": {
              "id": [media.id],
              "download_url": [URI.encode(download_url)]
            }
          }
        }
        respond_to do |format|
          format.json { render json: JSON.generate(json_obj)}
        end
      end
    end

    def cart_item_for_download_from_api
      @cart_item_for_download_from_api ||= find_item_for_download_from_api(media.id, download_hash, current_user.ms_id)
    end

    def create_or_update_cart_item_for_link_generation
      return nil unless (m = media_for_api).present?

      if (item = find_undownloaded_approved_request_item(m.id)).present?
        # Undownloaded approved request exists, associate download with request
        add_link_generation(item, download_hash)
      elsif (item = find_undownloaded_downloadable_item(m.id)).present?
        # Undownloaded downloadable item exists (e.g., in media cart), associated download
        add_link_generation(item, download_hash)
      elsif user_can_download?(current_user, m)
        item = create_cart_item_for_api(m)
      else
        item = nil
      end
      return item
    end


    private

      def validate_params_for_api_generate_download
        return render_json_by_http_code 401 unless user_from_authorization_header.present? 
        return render_json_by_http_code 404 unless media_for_api.present? 

        # the rest are validation failure
        errors = [] 
        unless use_statement.present? && use_statement.length >= 50
          errors << "use_statement with minimum 50 characters is required" 
        end 
        if use_categories.present? 
          unless use_categories.all? { |c| intended_use = Morphosource::UserProfile::CheckboxValues::INTENT.include?(c) }
            errors << "one or more values of use_categories are not valid"
          end
        elsif !use_categories_final.present?
          errors << "use_categories or use_category_other is required"
        end
        unless agreements_accepted?
          errors << "agreements_accepted is not set to true"
        end
        if errors.present?
          return render_json_by_http_code 400, errors
        end
      end

      # Get user record from api key in header
      def user_from_authorization_header
        User.where(token: api_key).first if api_key.present?
      end

      def user_from_token
        @user ||= user_from_authorization_header
      end

      def media_for_api
        return nil unless Media.exists? (params[:id])
        @media ||= Media.find(params[:id])
      end

      def api_key
        @api_key ||= request.headers['Authorization']
      end

      def download_hash
        @download_hash ||= begin
          if @is_api_generate_download
            SecureRandom.uuid
          else
            params[:download] if params[:download].present?
          end
        end
      end

      def validate_when_download_from_api
        @is_download_from_api = true
        return render_json_by_http_code 401 unless user_from_authorization_header.present? 
        return render_json_by_http_code 404 unless media_for_api.present? 
        return render_json_by_http_code 404 unless download_hash.present? 
        @current_user = user_from_token
        return render_json_by_http_code 404 unless cart_item_for_download_from_api.present?
      end
      
  end
end