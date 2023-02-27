module Morphosource
  class BatchEditsController < Hyrax::BatchEditsController

    # override Hyrax::BatchEditsController destroy_collection to prevent certain media to be deleted
    def destroy_collection
      msg = ""
      errors = []
      batch.each do |doc_id|
        obj = Media.find(doc_id)
        if obj.doi.present?
          errors << "#{doc_id} has a DOI" 
        elsif obj.child_media.present?
          errors << "#{doc_id} has child media" 
        elsif !obj.private?
          errors << "#{doc_id} is not private" 
        else
          obj.destroy
          msg = "Batch delete complete. "
        end
      end
      if errors.present?
        msg += "Media not deleted: " + errors.join(', ') 
      end
      flash[:notice] = msg 
      after_destroy_collection
    end

  end
end
