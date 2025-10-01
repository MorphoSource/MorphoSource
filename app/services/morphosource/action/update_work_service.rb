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
      attr_reader :work, :attributes, :files, :permissions_params, :form

      ##
      # Initialize the service specific to a work with attributes to be updated.
      #
      # @param work [Hyrax::Work] Valkyrie work resource object.
      # @param attributes [hash] Hash of key-value field attributes to for work. Do not nest attributes
      #                          in param-style work type key (?). Special keys to be handled include
      #                          :uploaded_files and :permissions_attributes.
      def initialize(work:, attributes:)
        @work = work
        @attributes = attributes

        uploaded_file_ids = attributes.delete(:uploaded_files)
        @files = Hyrax::UploadedFile.find(uploaded_file_ids) if uploaded_file_ids.present?
        @permissions_params = attributes.delete(:permissions_attributes)
        @form = Hyrax::FormFactory.new.build(work, nil, nil)
      end

      ##
      # Updates work. Will return result status object containing updated work or failure messages.
      #
      # @return [Result] Result monad, responds to :success? boolean, :value_or with block to return
      #                 created work or execute block if not present, and :failure as tuple with
      #                 0) symbol error and 1) failure object with :full_messages method.
      def call
        form.validate(attributes)
        transactions[transaction_name].with_step_args(**step_args).call(form)
      end

      private

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