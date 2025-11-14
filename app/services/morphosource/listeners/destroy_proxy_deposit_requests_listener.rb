module Morphosource
  module Listeners
    class DestroyProxyDepositRequestsListener
      ##
      # When a media is destroyed, finds and destroys proxy deposit requests associated with that media.
      #
      # @param event [Dry::Event]
      def on_object_deleted(event)
        # Check if :object key is present in event first. Somehow when a fileset is 
        # deleted (from Media Edit page), the FileSetActor triggers this deletion event
        return unless event.payload.key?(:object)

        case event[:object]
        when Media
          destroy_proxy_requests(event[:object])
        end
      end

      private

      def destroy_proxy_requests(work)
        if (transfers_to_destroy = ProxyDepositRequest.where(work_id: work.id)).present?
          transfers_to_destroy.each do |transfer|
            Rails.logger.info("Destroying ProxyDepositRequest #{transfer.id} for destroyed Media #{work.id}")
            transfer.destroy
          end
        end
      end
      
    end
  end
end