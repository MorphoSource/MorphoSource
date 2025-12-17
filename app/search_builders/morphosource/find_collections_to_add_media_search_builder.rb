class Morphosource::FindCollectionsToAddMediaSearchBuilder < Morphosource::FindWorksSearchBuilder
  # Find collections for adding media -- Projects, Teams, Media Lists

  self.default_processor_chain += [:exclude_media_lists_with_dois]

  def exclude_media_lists_with_dois(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "-doi_ssim:*"
  end

  def models
    [Collection, MediaList, SequentialSectionList]
  end
end