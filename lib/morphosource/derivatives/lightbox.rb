module Morphosource::Derivatives
  class LightboxError < RuntimeError
  end

  class Lightbox < DerivativeTool
    class_attribute :tool_url

    attr_reader :source_path, :out_path
    def initialize(source_path:, out_path:, tool_url: nil)
      @source_path = source_path
      @out_path = out_path
      @tool_url = tool_url
    end

    def call
      unless File.exists?(source_path)
        raise Morphosource::Derivatives::LightboxError.new("Source file: #{source_path} does not exist.")
      end

      internal_call
    end

    def tool_url
      @tool_url || Morphosource::Derivatives.lightbox_url
    end

    protected

    # Call lightbox API endpoint to create thumbnail
    def process_file
      response = RestClient::Request.execute(
        method:  :post, 
        url:     tool_url,
        payload: { file: File.open(source_path) },
        timeout: 300
      )

      if response.code == 200
        File.open(out_path, 'wb') { |file| file.write(response.body) }
        return response.code
      else
        raise Morphosource::Derivatives::LightboxError.new("Lightbox request returned non-successful response: Code #{response.code} with content #{response.body}")
      end
    rescue RestClient::BadRequest => e
      raise Morphosource::Derivatives::LightboxError.new("Lightbox returned 400 Bad Request")
    rescue RestClient::Exceptions::Timeout => e
      raise Morphosource::Derivatives::LightboxError.new("Lightbox request timed out")
    rescue StandardError => e
      raise Morphosource::Derivatives::LightboxError.new("Lightbox request returned error with #{e.message}")
    end

    def post_process(raw_output)
      # Check for produced derivative file, otherwise raise Lightbox response as error
      if !File.exists?(out_path) || (File.size(out_path) == 0)
        raise Morphosource::Derivatives::LightboxError.new("File not successfully created by derivative tool.\nAPI response code: #{raw_output}")
      end
    end
  end
end