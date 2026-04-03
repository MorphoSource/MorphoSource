# frozen_string_literal: true

module Morphosource
  module Transactions
    module Steps
      ##
      # Extends Hyrax's DeleteResource step to include deleted_ark in the
      # object.deleted event payload, enabling ARK reservation cleanup on destroy.
      class DeleteResource < Hyrax::Transactions::Steps::DeleteResource
        private

        def publish_changes(resource:, user:)
          if resource.collection?
            @publisher.publish('collection.deleted',
                               collection: resource,
                               id: resource.id.id,
                               user: user)
          else
            deleted_ark = resource.respond_to?(:ark) ? Array(resource.ark).first : nil
            @publisher.publish('object.deleted',
                               object: resource,
                               id: resource.id.id,
                               user: user,
                               deleted_ark: deleted_ark)
          end
        end
      end
    end
  end
end
