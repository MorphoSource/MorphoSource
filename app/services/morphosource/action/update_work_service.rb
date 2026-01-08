# frozen_string_literal: true

module Morphosource
  module Action
    ##
    # @since 5.0.0
    # @api public
    #
    # Service to update Valkyrie work resource object. Compared to ActiveFedora "thick" works that
    # encapsulate their own methods for save, update, delete, etc., Valkyrie uses "thin" models
    # where attribute validation and work create/update/delete are carried out through interactions
    # between multiple related modules. This service integrates the logic flow for updating a single
    # Valkyrie work, and should be used anywhere outside of a work's primary controller for updating
    # works.
    class UpdateWorkService
      attr_reader :work, :params, :work_attributes_key, :work_attributes, :files, :permissions_params, :form

      ##
      # Initialize the service specific to a work with attributes to be updated.
      #
      # @param work [Hyrax::Work] Valkyrie work resource object.
      # @param params [hash] The contextual parameters for the action; ApplicationController#params
      # @param work_attributes_key [Symbol] the name of the key within the params that contains
      #                                     the work's attributes. Optional, will try to use model
      def initialize(work:, params:, work_attributes_key: nil, skip_index_related_works: false)
        @work = work
        @params = params
        @work_attributes_key = work_attributes_key

        @work_attributes = params.fetch(attributes_key, {})
        uploaded_file_ids = params.fetch(:uploaded_files, [])
        @files = Hyrax::UploadedFile.find(uploaded_file_ids) if uploaded_file_ids.present?
        @permissions_params = params.fetch(:permissions, [])
        @form = Hyrax::FormFactory.new.build(work, nil, nil)
        form.skip_index_related_works = true if skip_index_related_works
      end

      ##
      # Updates work. Will return result status object containing updated work or failure messages.
      #
      # @return [Result] Result monad, responds to :success? boolean, :value_or with block to return
      #                 created work or execute block if not present, and :failure as tuple with
      #                 0) symbol error and 1) failure object with :full_messages method.
      def call
        if form.validate(work_attributes)
          transactions[transaction_name].with_step_args(**step_args).call(form)
        else
          errors = ( form.errors&.messages || {} ).map { |k, vs| vs.map { |v| "#{k} #{v}" } }.flatten.to_sentence
          raise "Error updating #{work.model_name} #{work.id.to_s}: #{errors}"
        end
      end

      private

      def attributes_key
        work_attributes_key.nil? ? work.model_name.to_s.underscore.to_sym : work_attributes_key
      end

      def transactions
        Hyrax::Transactions::Container
      end

      def transaction_name
        case work.model_name
        when 'TaxonomyResource'
          'taxonomy_change_set.update_work'
        else
          raise "Unpermitted work type #{work.class}"
        end
      end

      def step_args
        case work.model_name
        when 'TaxonomyResource'
          {
            'work_resource.save_acl' => { permissions_params: permissions_params }
          }
        else
          raise "Unpermitted work type #{work.class}"
        end
      end
    end
  end
end