module Morphosource
  class RemoteFileVerificationService

    def self.call(media)
    	new(media).call
    end

    def initialize(media)
    	@media = media
      @file_set = @media.file_sets&.first
    end

    def call
      return nil unless @media.remote_origin_url.present?
      return nil unless @file_set.present?
      rfi = MorphosourceHelper::RemoteFileInfo.new(@media.remote_origin_url)
      return rfi if rfi.status != "success" # there is an error already (e.g. 404)
      messages = []
      if !(e_tag = rfi.e_tag).present?
        messages << "ETag not in request"        
      elsif e_tag != @file_set.e_tag
        messages << "ETag #{e_tag} does not match existing media's ETag #{@file_set.e_tag}"
      end
      if !(content_length = rfi.content_length).present? 
        messages << "content_length not in request"
      elsif content_length != @file_set.file_size&.first
        messages << "content_length #{rfi.content_length} does not match existing media's file_size #{@file_set.file_size&.first}"
      end
      return nil if messages.empty?
      rfi.message = messages.join('; ')
      return rfi
    end

  end
end
