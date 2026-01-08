module Morphosource
  module Transactions
    module Steps
      # Compared to Hyrax version, allows ability to skip indexing related works
      class Save < Hyrax::Transactions::Steps::Save
        ##
        # @param [Hyrax::ChangeSet] change_set
        # @param [::User, nil] user
        #
        # @return [Dry::Monads::Result] `Success(work)` if the change_set is
        #   applied and the resource is saved;
        #   `Failure([#to_s, change_set.resource])`, otherwise.
        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        def call(change_set, user: nil)
          begin
            valid_future_date?(change_set.lease, 'lease_expiration_date') if change_set.respond_to?(:lease) && change_set.lease
            valid_future_date?(change_set.embargo, 'embargo_release_date') if change_set.respond_to?(:embargo) && change_set.embargo
            new_collections = changed_collection_membership(change_set)

            unsaved = change_set.sync
            save_lease_or_embargo(unsaved)
            saved = @persister.save(resource: unsaved)
          rescue StandardError => err
            return Failure.new(["Failed save on #{change_set}\n\t#{err.message}", change_set.resource], err.backtrace.first)
          end

          # if we have a permission manager, it's acting as a local cache of another resource.
          # we want to resync changes that we had in progress so we can persist them later.
          saved.permission_manager.acl.permissions = unsaved.permission_manager.acl.permissions if
            unsaved.respond_to?(:permission_manager)

          user ||= ::User.find_by_user_key(saved.depositor)

          skip_index_related_works = change_set.respond_to?(:skip_index_related_works) && change_set.skip_index_related_works

          publish_changes(
            resource: saved,
            user: user,
            new: unsaved.new_record,
            new_collections: new_collections,
            skip_index_related_works: skip_index_related_works
          )
          Success(saved)
        end

        private

        def publish_changes(resource:, user:, new: false, new_collections: [], skip_index_related_works: false)
          if resource.collection?
            @publisher.publish('collection.metadata.updated', collection: resource, user: user, skip_index_related_works: skip_index_related_works)
          else
            @publisher.publish('object.deposited', object: resource, user: user) if new
            @publisher.publish('object.metadata.updated', object: resource, user: user, skip_index_related_works: skip_index_related_works)
          end

          new_collections.each do |collection_id|
            @publisher.publish('collection.membership.updated',
                               collection_id: collection_id,
                               user: user)
          end
        end
      end
    end
  end
end