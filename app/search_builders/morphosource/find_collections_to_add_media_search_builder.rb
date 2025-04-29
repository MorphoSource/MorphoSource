class Morphosource::FindCollectionsToAddMediaSearchBuilder < Morphosource::FindWorksSearchBuilder
  # Find collections for adding media -- Projects, Teams, Media Lists
  def models
    [Collection, MediaList, SequentialSectionList]
  end
end