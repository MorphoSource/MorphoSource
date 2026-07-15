module Morphosource
  module CartItems
    module RequestMessages
      include Morphosource::MessageHelper

      def max_for_details
        @max_for_details ||= Hyrax.config.max_for_download_request_details
      end

      # Returns the users and org collections to display as the recipients of a
      # download request notification. When download_reviewer contains org ids,
      # those orgs are shown rather than their members. When download_reviewer is
      # empty and user_with_ownership is an org, that org is shown. Otherwise
      # falls back to the resolved individual reviewers.
      def reviewer_display_targets(work_doc, reviewers)
        download_reviewers = Array(work_doc['download_reviewer_ssim'])

        if download_reviewers.present?
          resolved = Morphosource::DownloadReviewerResolverService.resolve_objects(download_reviewers)
          resolved.present? ? resolved : reviewers
        else
          org_owner = OrganizationCollection.find_by(id: work_doc["user_with_ownership_ssi"])
          org_owner.present? ? org_owner : reviewers
        end
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
            Array(work.reviewers).each do |r|
              if User.where(ms_id:r).present?
                # todo: check and skip if current reviewer?
                reviewers << User.where(ms_id:r).first
              end
            end
            if message_for == "reviewer" && Array(work.reviewers).count > 1
              content += "<br/><small>(This request has been sent to multiple reviewers: #{user_email_link(reviewers)} who are all able to approve, deny, or clear this request.  Please coordinate your response if appropriate.)</small>"
            elsif message_for == "requestor"
              content += "<br/><small>(This request has been sent to: #{user_or_org_email_link(reviewer_display_targets(work, reviewers))})</small>"
            end
            content += "</p>"
          end
        end
        return content.html_safe
      end
    end
  end
end
