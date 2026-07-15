module Morphosource
  class MergeBiologicalSpecimenService

    def self.call(merge_to=nil, merge_from=nil, delete_dup=true, report_only=false, reporter: nil)
    	new(merge_to, merge_from, delete_dup, report_only, reporter: reporter).call
    end

    def initialize(merge_to, merge_from, delete_dup, report_only, reporter: nil)
    	@merge_to = merge_to
    	@merge_from = merge_from
    	@delete_dup = delete_dup
    	@report_only = report_only
    	@reporter = reporter || Morphosource::DualLogger.new
    end

    def call
      bso_to = BiologicalSpecimen.find(@merge_to)
      bso_from = BiologicalSpecimen.find(@merge_from)
		  ie_list = []
		  media_list = []
		  failed_repoints = []
		  bso_from.media.each do |m|
        # detach media's IE, add IE under target bso, reindex bso (reindex media and related media should be triggered after)
        media_list << m.id
        ie = m.imaging_event
        ie_list << ie.id
        ie.physical_object_id = [bso_to.id]
        if !@report_only && !ie.save
          failed_repoints << ie.id
          @reporter.log " failed to repoint ImagingEvent #{ie.id} (media #{m.id}) from #{@merge_from} to #{@merge_to}", level: :warn
        end
		  end
      if media_list.present? && !@report_only
        # reindex bso_to specimens (ie.save above will reindex bso_from specimens)
        UpdateWorkIndexJob.perform_later(@merge_to)
      end
		  if @delete_dup && !@report_only
		  	if failed_repoints.present?
		  	  @reporter.log " specimen #{@merge_from} NOT destroyed -- #{failed_repoints.count} ImagingEvent(s) failed to repoint: #{failed_repoints.inspect}", level: :warn
		  	elsif media_still_referencing?(bso_from, media_list)
		  	  @reporter.log " specimen #{@merge_from} NOT destroyed -- Solr still shows media referencing it beyond what this merge already handled", level: :warn
		  	else
		  	  bso_from.destroy
		  	  @reporter.log " specimen #{@merge_from} destroyed"
		  	end
		  end
		  return media_list, ie_list
    end

    private

    # Re-checks, with a forced hard commit, whether Solr still reports any media under
    # bso_from that this merge did NOT already find and repoint. This catches soft-commit
    # lag (a legitimate reindex that ran but hadn't become searchable yet), but it cannot
    # catch media whose real (Fedora) link to bso_from was never indexed in the first place
    # (e.g. an ImagingEvent repointed via skip_index_related_works, or any other path that
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
