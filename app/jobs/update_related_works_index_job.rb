# Updates solr records for related works when related work information is stored in the related works' solr. Example: When an organization title is updated, this makes sure that all of the organization's media solr records have the updated title.

# Called from Morphosource::IndexRelatedWorks

class UpdateRelatedWorksIndexJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.update_fast_queue_name

  def perform(work_ids)
    return unless work_ids.present?

    if Collection.exists?(work_ids.first)
      reindex_collections(work_ids)
    else
      work_ids.each do |work_id|
        UpdateWorkIndexJob.perform_later(work_id)
      end
    end
  end

  def reindex_collections(collection_ids)
    collection_ids.each do |c_id|
      if Collection.exists?(c_id)
        c = Collection.find(c_id)
        c.update_index
      end
    end
  end
end
