# frozen_string_literal: true
module Hyrax
  # Grants the user's edit access on the provided FileSet
  class GrantEditJob < ApplicationJob
    include PermissionJobBehavior
    # @param file_set_id [String] the identifier of the object to grant access to
    # @param user_key [String] the user to add
    # @param use_valkyrie [Boolean] unused; retained for backward compatibility with serialized jobs
    def perform(file_set_id, user_key, use_valkyrie: Hyrax.config.use_valkyrie?)
      file_set = Hyrax.query_service.postgres_service.find_by(id: Valkyrie::ID.new(file_set_id))
      AccessControlList.new(resource: file_set).grant(:edit).to(user(user_key)).save
    rescue Valkyrie::Persistence::ObjectNotFoundError
      file_set = ::FileSet.find(file_set_id)
      file_set.edit_users += [user_key]
      file_set.save!
    end
  end
end
