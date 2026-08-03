module Morphosource
  class MergeBiologicalSpecimenService

    def self.call(merge_to=nil, merge_from=nil, delete_dup=true, report_only=false)
    	new(merge_to, merge_from, delete_dup, report_only).call
    end

    def initialize(merge_to, merge_from, delete_dup, report_only)
    	@merge_to = merge_to
    	@merge_from = merge_from
    	@delete_dup = delete_dup
    	@report_only = report_only
    end

    def call
      bso_to = BiologicalSpecimen.find(@merge_to)
      bso_from = BiologicalSpecimen.find(@merge_from)
		  ie_list = []
		  media_list = []
		  outcome = nil
		  # No rollback on a mid-loop failure: already-reassigned IEs stay reassigned. Safe
		  # but incomplete -- a retry picks up the rest.
		  bso_from.media.each do |m|
        # detach media's IE, add IE under target bso
        media_list << m.id
        ie = m.imaging_event
        ie_list << ie.id
        ie.physical_object_id = [bso_to.id]
        if !@report_only && !ie.save
          # Deliberately fatal -- the caller stops the run instead of skipping and continuing.
          raise "Failed to reassign ImagingEvent #{ie.id} (media #{m.id}) from specimen #{@merge_from} to #{@merge_to}"
        end
        # Media's own Solr doc caches physical_object_id_ssim -- it won't reflect the
        # reassigned IE until the media itself is reindexed, so do that explicitly here
        # rather than relying on some other reindex path to eventually cover it.
        UpdateWorkIndexJob.perform_later(m.id) unless @report_only
		  end
      if media_list.present? && !@report_only
        # reindex bso_to specimens (ie.save above will reindex bso_from specimens)
        UpdateWorkIndexJob.perform_later(@merge_to)
      end
		  if @delete_dup && !@report_only
		  	if media_still_referencing?(bso_from, media_list)
		  	  outcome = :not_destroyed_media_referencing
		  	  puts " specimen #{@merge_from} NOT destroyed -- Solr still shows media referencing it beyond what this merge already handled"
		  	else
		  	  if bso_from.destroy
		  	    outcome = :destroyed
		  	    puts " specimen #{@merge_from} destroyed"
		  	  else
		  	    outcome = :destroy_vetoed_by_guard
		  	    puts " specimen #{@merge_from} NOT destroyed -- destroy call was vetoed (e.g. by the has-media guard): #{bso_from.errors.full_messages.join('; ')}"
		  	  end
		  	end
		  end
		  return media_list, ie_list, outcome
    end

    private

    # Forces a Solr commit and re-checks for media under bso_from beyond what was already
    # handled. Catches soft-commit lag, not media that was never indexed in the first place.
    def media_still_referencing?(bso_from, already_handled_media_ids)
      ActiveFedora::SolrService.commit
      qry = "physical_object_id_ssim:#{bso_from.id} AND has_model_ssim:Media"
      found_ids = ActiveFedora::SolrService.query(qry, rows: 999_999).map(&:id)
      (found_ids - already_handled_media_ids).present?
    end

  end
end
