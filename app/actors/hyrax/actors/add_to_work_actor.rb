# Overrides Hyrax app/actors/hyrax/actors/add_to_work_actor.rb

# When a user edits parent work relationships, the edit form will display a list of the work's current parents, each with a button to remove the relationship. Additional parents can be added to the list by using a search box.
# ENV attributes passed to the actor include a hash of works to keep, add, or remove as parents of the current work. The works may or may not already be parents of the current work.
# The parent relationship is recorded on the parent work; the current work's id will be added or removed from the parent's children as required. The current work will not be changed.
# If a work is already a parent and has destroy 'false' OR if a work is not already a parent and has 'destroy' true, those works will not be processed.
# Example:
# "work_parents_attributes"=>
#   {
#     "0"=>{"id"=>"nk322d32h", "_destroy"=>"false"},  ( <-- previously added parent )
#     "1"=>{"id"=>"db78tc01m", "_destroy"=>"true"},   ( <-- previously added parent to be removed )
#     "2"=>{"id"=>"bg257f046", "_destroy"=>"false"}   ( <-- new parent to be added )
#   }

module Hyrax
  module Actors
    class AddToWorkActor < AbstractActor
      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] true if create was successful
      def create(env)
        env.attributes.delete(:in_works_ids)
        parent_works_hash = env.attributes["work_parents_attributes"]
        next_actor.create(env) && add_to_works(env, parent_works_hash)
      end

      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] true if update was successful
      def update(env)
        env.attributes.delete(:in_works_ids)
        parent_works_hash = env.attributes["work_parents_attributes"]
        add_to_works(env, parent_works_hash) && next_actor.update(env)
      end

      private

        def add_to_works(env, parents)
          return true if parents.nil?
          cleanup_ids_to_remove_from_curation_concern(env, parents)
          add_new_work_ids_not_already_in_curation_concern(env, parents)
          env.curation_concern.errors[:in_works_ids].empty?
        end

        # For each parent work, if destroy is true and it is a parent of the current work, remove the current work from the parent's members.
        # work/work_id = parent work
        # env.curation_concern = child work

        def cleanup_ids_to_remove_from_curation_concern(env, parents)
          work_ids_to_remove = []
          parents.each do |k,v|
            if (v["_destroy"] == "true" && env.curation_concern.in_works_ids.include?(v["id"]))
              work_ids_to_remove << v["id"]
            end
          end

          work_ids_to_remove.each do |old_id|
            work = ::ActiveFedora::Base.find(old_id)
            work.ordered_members.delete(env.curation_concern)
            work.members.delete(env.curation_concern)
            work.save!
          end
        end

        # For each parent work, if destroy is false and it is not already a parent of the current work, add the current work to the parent's members.
        # It is possible to add the same work multiple times; 'uniq' removes duplicate parent works.
        # work/work_id = parent work
        # env.curation_concern = child work

        def add_new_work_ids_not_already_in_curation_concern(env, parents)
          work_ids_to_add = []
          parents.each do |k,v|
            if (v["_destroy"] == "false" && env.curation_concern.in_works_ids.exclude?(v["id"]))
              work_ids_to_add << v["id"]
            end
          end

          work_ids_to_add.uniq.each do |work_id|
            work = ::ActiveFedora::Base.find(work_id)
            work.ordered_members << env.curation_concern
            work.save!
          end
        end
    end
  end
end
