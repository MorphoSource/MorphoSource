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
      return ["No remote_origin_url"] unless @media.remote_origin_url.present?
      return ["No file_set"] unless @file_set.present?
      rfi = MorphosourceHelper::RemoteFileInfo.new(@media.remote_origin_url)
      return [rfi.message] if rfi.status != "success" # there is an error already (e.g. 404)
      issues = []
      if !(e_tag = rfi.e_tag).present?
        issues << "ETag not in request headers"        
      elsif e_tag != @file_set.e_tag
        issues << "ETag (#{e_tag}) does not match stored media's ETag (#{@file_set.e_tag})"
      end
      if !(content_length = rfi.content_length).present? 
        issues << "content_length not in request headers"
      elsif content_length != @file_set.file_size&.first
        issues << "content_length (#{rfi.content_length}) does not match stored media's file_size (#{@file_set.file_size&.first})"
      end
      return issues
    end

  end
end
