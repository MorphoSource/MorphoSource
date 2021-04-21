# Updates solr records for related works when related work information is stored in the related works' solr. Example: When an organization title is updated, this makes sure that all of the organization's media solr records have the updated title.

# Called from Morphosource::IndexRelatedWorks

class UpdateRelatedWorksIndexJob < Hyrax::ApplicationJob

  def perform(works)
    return if works.blank?
    
    if works.first.collection?
      reindex_collections(works)
    else
      works.each do |work|
        work.update_index if ::ActiveFedora::Base.exists?(work.id)
      end
    end
  end

  def reindex_collections(collections)
    collections.each do |c|
      c.reindex_extent = ::Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
      c.update_index
    end
  end
end
