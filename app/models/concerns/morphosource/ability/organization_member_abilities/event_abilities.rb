module Morphosource
  module Ability
    module OrganizationMemberAbilities
      module EventAbilities
        # returns true if the user has read or edit access to the imaging event through the organization collection
        def has_organizational_access_to_event?(event)
          Rails.logger.debug("[CANCAN] Checking for individual imaging event access through organization membership")
          return false unless event = solr_document(event)

          event_media = detect_child_media(event)
          return false unless event_media.present?

          event_media.each do |media|
            media = solr_document(media)
            return true if has_organizational_access_to_media?(media)
            return true if has_organizational_edit_access_to_media?(media)

          end
          false
        end

        # # returns true if the user has edit access to the event's child media
        def has_organizational_edit_access_to_event?(event)
          Rails.logger.debug("[CANCAN] Checking for individual physical object edit access through organization membership")
          return false unless event = solr_document(event)

          event_media = detect_child_media(event)
          return false unless event_media.present?

          event_media.each do |media|
            media = solr_document(media)
            return true if has_organizational_edit_access_to_media?(media)

          end
          false
        end

        private

        # returns an array of closest ancestor media solr hits for the event
        def detect_child_media(event)
          return [] unless member_ids = event['member_ids_ssim']
          member_docs = Morphosource::SolrService.new.get_docs(nil, fq: ["id:(#{member_ids.join(' OR ')})"])
          # if the event has an immediate child media, return it
          media = member_docs.select { |doc| doc['has_model_ssim'] == ['Media'] }
          return media if media.present?
          # otherwise return the members' child media
          member_doc_member_ids = member_docs.map{|doc| doc['member_ids_ssim']}.flatten
          return [] unless member_doc_member_ids.compact.present?

          media = Morphosource::SolrService.new.get_docs(nil, fq: ["id:(#{member_doc_member_ids.join(' OR ')}) AND has_model_ssim:Media"])
        end
      end
    end
  end
end