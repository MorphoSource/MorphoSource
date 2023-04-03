module Morphosource
  module CartItems
    module RequestMessages

      def host_name
        @host_name ||= Hyrax.config.host_name
      end

      def email_sender
        @email_sender ||= User.where(email: Hyrax.config.contact_email)&.first
      end

      def user_email_link(users)
        users = [users] if users.kind_of?(User)
        list = []
        users.each do |user|
          if user.display_name.present?
            list << "#{user.display_name} (<a href='mailto:#{user.email}'>#{user.email}</a>)"
          else
            list << "<a href='mailto:#{user.email}'>#{user.email}</a>"
          end
        end
        return list.to_sentence.html_safe
      end

      def max_for_details
        @max_for_details ||= Hyrax.config.max_for_download_request_details
      end

      def cart_item_message_content(items, message_for="requestor")
        content = ""
        items.each do |item|
          work = SolrDocument.find(item.work_id)
          if work.present?
            content += "<p>" +
              "<b><a href='http://#{host_name}/media/#{work.id}'>Media #{work.id}: #{work.title.first}</a></b>"
            object = work.objects&.first
            if object.present?
              if object.specimen?
                content += " of " + work.physical_object_type.downcase + " <b><a href='http://#{host_name}/biological_specimens/#{object.id}'>#{object.title.first}</a>" + "</b>"
                if object.taxonomies_titles.present?
                  content += " (<i>" + object.taxonomies_titles.first + "</i>)"
                end
              else
                content += " of " + work.physical_object_type.downcase +
                  " <b><a href='http://#{host_name}/cultural_heritage_objects/#{object.id}'>#{object.title.first}</a>" + "</b>"
              end
            end
            content += " for intended use: <i>\"" + item.use + "\"</i>" if item.use.present?
            reviewers = []
            Array(work.reviewer).each do |r|
              if User.where(ms_id:r).present?
                # todo: check and skip if current reviewer?
                reviewers << User.where(ms_id:r).first
              end
            end
            if message_for == "reviewer" && Array(work.reviewer).count > 1
              content += "<br/><small>(This request has been sent to multiple reviewers: #{user_email_link(reviewers)} who are all able to approve, deny, or clear this request.  Please coordinate your response if appropriate.)</small>"
            elsif message_for == "requestor"
              content += "<br/><small>(This request has been sent to: #{user_email_link(reviewers)})</small>"
            end
            content += "</p>"
          end
        end
        return content.html_safe
      end

      def deliver(sender, recipients, message, subject)
        begin
          Hyrax::MessengerService.deliver(sender, recipients, message, subject)
          # arguments passed to messenger_service: (sender, recipients, body, subject, *args)
        rescue => e
          Rails.logger.debug "Error sending message. Exception: #{ e.message }.  Make sure sender account in MS and HOST_NAME in environment is setup correctly."
        end
      end

    end
  end
end
