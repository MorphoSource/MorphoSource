module Morphosource
  class RemoteFileVerificationService

    def self.call(media)
    	new(media).call
    end

    def initialize(media)
    	@media = media
    end

    def call
      return nil unless @media.remote_origin_url.present?
      rfi = MorphosourceHelper::RemoteFileInfo.new(@media.remote_origin_url)
      return rfi if rfi.status != "success" # there is an error already (e.g. 404)
      messages = []
      if !rfi.last_modified.present?
        messages << "last_modified not in request"        
      else

        #
         
      end
      if !(content_length = rfi.content_length).present? 
        messages << "content_length not in request"
      end
      if !(file_size = @media.file_sets&.first&.file_size&.first).present?
        messages << "existing file_size not available"
      end
      if content_length.present? && file_size.present? && content_length != file_size
        messages << "content_length #{rfi.content_length} does not match existing file_size #{file_size}"
      end

      return nil if messages.empty?

      rfi.message = messages.join('; ')
      return rfi
    end

  end
end
