# Solr-based methods for finding works by traversing Media relationship hierarchy.
module MediaFinderHelper
  include SolrHelper

  #
  # Solr service instance
  #
  # @return [SolrService] Solr service instance
  #
  def solr
    @solr ||= solr_service.new
  end
  
  #
  # Works upstream from solr_document, default limit of 15 works upstream in hierarchy.
  #
  # @param [SolrDocument] solr_document Media or other SolrDocument to travel upstream from
  # @param [Integer] limit Limit of works upstream to trawl and return
  #
  # @return [Array<SolrDocument>] Array of SolrDocuments of parent upstream works in parent-child order
  #
  def parent_works(solr_document, limit = 15)
    return [] unless solr_document.present?

    parents = []
    member_id = solr_document.id
    n = 0
    while ( parent = work_with_member(member_id) ).present? && ( n < limit ) do
      n += 1
      parents << parent
      member_id = parent.id
    end
    return parents.reverse
  end

  #
  # Find "parent" upstream SolrDocument by "child" downstream work ID 
  #
  # @param [String] member_id Child downstream work ID
  #
  # @return [SolrDocument] Parent upstream work document
  #
  def work_with_member(member_id)
    ::SolrDocument.where("member_ids_ssim" => member_id)&.first
  end

  #
  # IDs of immediate direct next-generation "child" downstream Media works/
  # Assumes a Media membership hierarchy of ... -> Media -> PE -> Media.
  #
  # @param [SolrDocument] solr_document SolrDocument for Media to find children for
  #
  # @return [Array<String>] Array of child downstream Media works
  #
  def direct_child_media_ids(solr_document)
    return [] unless solr_document.member_ids.present?

    processing_events = solr.get_docs(
      "#{assemble_or_query("id", solr_document.member_ids)} AND has_model_ssim:ProcessingEvent",
      { fl: ["id", "has_model_ssim", "member_ids_ssim"] }
    )
    processing_event_member_ids = processing_events.map { |pe| pe["member_ids_ssim"] }.flatten.uniq
    return [] unless processing_event_member_ids.present?

    solr.get_docs(
      "#{assemble_or_query("id", processing_event_member_ids)} AND has_model_ssim:Media",
      { fl: ["id"] }
    ).map { |doc| doc["id"] }
  end
end
