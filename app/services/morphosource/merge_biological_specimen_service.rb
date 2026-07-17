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
		  # No rollback on a mid-loop failure below: if e.g. the 3rd of 5 media's ImagingEvent
		  # fails to save, the raise stops the run and correctly leaves bso_from un-destroyed,
		  # but the 2 IEs that already saved successfully are NOT reverted -- they keep pointing
		  # at bso_to while the rest still point at bso_from. This is a safe, resumable partial
		  # state (not a corrupted one): the already-reassigned media are correctly on bso_to,
		  # bso_from is untouched and still owns its remaining media, and a retry naturally
		  # picks up just what's left. Deliberately not rolling back -- doing so would add
		  # complexity and its own failure mode (the rollback's own ie.save calls could fail
		  # too, e.g. if the original failure was systemic, potentially leaving things worse).
		  bso_from.media.each do |m|
        # detach media's IE, add IE under target bso, reindex bso (reindex media and related media should be triggered after)
        media_list << m.id
        ie = m.imaging_event
        ie_list << ie.id
        ie.physical_object_id = [bso_to.id]
        if !@report_only && !ie.save
          # Deliberately fatal: raise instead of tracking-and-continuing, so the caller
          # (the dedupe rake task) stops the whole run rather than silently skipping this
          # specimen and moving on. The caller is responsible for catching this, emailing
          # the log, and failing the process.
          raise "Failed to reassign ImagingEvent #{ie.id} (media #{m.id}) from specimen #{@merge_from} to #{@merge_to}"
        end
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
		  	  bso_from.destroy
		  	  outcome = :destroyed
		  	  puts " specimen #{@merge_from} destroyed"
		  	end
		  end
		  return media_list, ie_list, outcome
    end

    private

    # Re-checks, with a forced hard commit, whether Solr still reports any media under
    # bso_from that this merge did NOT already find and reassign. This catches soft-commit
    # lag (a legitimate reindex that ran but hadn't become searchable yet), but it cannot
    # catch media whose real (Fedora) link to bso_from was never indexed in the first place
    # (e.g. an ImagingEvent reassigned via skip_index_related_works, or any other path that
    # never queued a reindex job) -- Solr has no record of that relationship to find, no
    # matter when or how often it's queried. Closing that gap fully requires either an
    # authoritative (non-Solr) reverse lookup or a has-media guard at the model/actor level.
    def media_still_referencing?(bso_from, already_handled_media_ids)
      ActiveFedora::SolrService.commit
      qry = "physical_object_id_ssim:#{bso_from.id} AND has_model_ssim:Media"
      found_ids = ActiveFedora::SolrService.query(qry, rows: 999_999).map(&:id)
      (found_ids - already_handled_media_ids).present?
    end

  end
end
