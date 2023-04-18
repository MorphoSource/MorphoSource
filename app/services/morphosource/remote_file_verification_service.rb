module Morphosource
  class RemoteFileVerificationService

    def self.call(media)
    	new(media).call
    end

    def initialize(media)
    	@media = media
    end

    def call
      media = @media
      if !media.remote_origin_url.present?
        return nil
      else
        rfi = MorphosourceHelper::RemoteFileInfo.new(media.remote_origin_url)
        if rfi.last_modified.present?
          
          #
           
        end
        if (content_length = rfi.content_length).present? && 
            (file_size = media.file_sets&.first&.file_size&.first).present?
          byebug
          if content_length != file_size
            rfi.message = "content_length #{rfi.content_length} does not match existing file_size "
          end
        end
        return rfi
      end
    end

  end
end
