module Morphosource
  # Functionality that should be applied to all Valkyrie forms goes here
  module ValkyrieFormBehavior
    extend ActiveSupport::Concern

    included do
      property :id
      property :skip_index_related_works
    end

    # Valkyrie-aware replacement for Morphosource::FormMethods#member_of_works_json.
    # Valkyrie::Resource#to_key always returns [id], even [nil] for new records.
    # Rails dom_id treats a non-nil to_key as a persisted record, generating
    # "imaging_event_resource_" instead of "new_imaging_event_resource".
    # Return nil when unpersisted so dom_id generates the correct "new_" prefix.
    def to_key
      model.id.present? ? [model.id] : nil
    end

    # Queries Valkyrie parents via find_inverse_references_by, and also falls back
    # to AF in_works if the model supports it (for transitional mixed environments).
    def member_of_works_json(work_type = nil)
      valkyrie_parents = if model.persisted?
        Hyrax.query_service
             .find_inverse_references_by(resource: model, property: :member_ids)
             .select { |r| r.respond_to?(:work?) ? r.work? : true }
      else
        []
      end

      af_parents = model.respond_to?(:in_works) ? model.in_works : []

      parent_works = valkyrie_parents + af_parents

      if @controller&.params&.[](:parent_id).present?
        id = @controller.params[:parent_id]
        begin
          parent_works += [Hyrax.query_service.find_by(id: Valkyrie::ID.new(id))]
        rescue Valkyrie::Persistence::ObjectNotFoundError
          begin
            parent_works += [ActiveFedora::Base.find(id)]
          rescue ActiveFedora::ObjectNotFoundError, Ldp::Gone
            nil
          end
        end
      end

      if work_type.present?
        parent_works = parent_works.select { |item| item.class.to_s == work_type }
      end

      parent_works.map do |parent|
        {
          id: parent.id.to_s,
          label: parent.to_s,
          path: @controller.url_for(parent)
        }
      end.to_json
    end
  end
end