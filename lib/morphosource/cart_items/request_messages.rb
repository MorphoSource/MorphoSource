module Morphosource
  module CartItems
    module RequestMessages

      def host_name
        @host_name ||= Hyrax.config.host_name
      end

      def email_sender
        # todo: look up sender from config instead
        @email_sender ||= User.where(email: 'morphosource@duke.edu')&.first
      end

      def cart_item_message_content(item, work)
        return @cart_item_message_content if @cart_item_message_content.present?
        content = "the media <b><a href='http://#{host_name}/media/#{work.id}'>#{work.title.first}</a></b>"
        object = work.objects&.first
        if object.present?
          if object.specimen?
            content += " of " + work.physical_object_type.downcase + " <b><a href='http://#{host_name}/biological_specimens/#{object.id}'>#{object.title.first}</a>" + "</b>" + " (" + object.taxonomies_titles&.first + ")"
          else
            content += " of " + work.physical_object_type.downcase + 
              " <b><a href='http://#{host_name}/cultural_heritage_objects/#{object.id}'>#{object.title.first}</a>" + "</b>" 
          end
        end
        content += " for intended use: <i>\"" + item.use + "\"</i>" if item.use.present?
        @cart_item_message_content = content.html_safe + ".  "
        return @cart_item_message_content
      end

      def deliver(sender, recipient, message, subject)
        begin
          Hyrax::MessengerService.deliver(sender, recipient, message, subject)
          # arguments passed to messenger_service: (sender, recipients, body, subject, *args)
        rescue => e
          Rails.logger.debug "Error sending message. Exception: #{ e.message }"
        end
      end

    end
  end
end
