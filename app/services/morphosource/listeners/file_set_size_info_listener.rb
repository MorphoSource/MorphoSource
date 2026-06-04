# frozen_string_literal: true

module Morphosource
  module Listeners
    # Ensures FileSetSizeInfo rows stay in sync with the FileSet lifecycle via
    # the Hyrax publisher event bus. The AF FileSet model also fires after_create
    # / after_destroy callbacks; these listener methods are idempotent complements.
    class FileSetSizeInfoListener
      def on_object_deposited(event)
        object = event.respond_to?(:payload) ? event.payload[:object] : nil
        return unless object.is_a?(FileSet)
        FileSetSizeInfo.find_or_create_by!(file_set_id: object.id.to_s)
      rescue => e
        Rails.logger.error "FileSetSizeInfoListener#on_object_deposited failed for #{object&.id}: #{e.message}"
      end

      def on_object_deleted(event)
        object = event.respond_to?(:payload) ? event.payload[:object] : nil
        id = object.respond_to?(:id) ? object.id.to_s : event.payload[:id]&.to_s
        return unless id.present?
        # Direct FileSet deletion — id is the FileSet's own ID
        FileSetSizeInfo.find_by(file_set_id: id)&.destroy
        # Parent Work deletion — Hyrax orphans FileSets rather than destroying them,
        # so object.deleted fires for the Work but not each FileSet; clean up by media_id.
        FileSetSizeInfo.where(media_id: id).destroy_all
      rescue => e
        Rails.logger.error "FileSetSizeInfoListener#on_object_deleted failed for #{id}: #{e.message}"
      end
    end
  end
end
