# frozen_string_literal: true

module Morphosource
  module Action
    ##
    # @since 5.0.0
    # @api public
    #
    # Service to create Valkyrie work resource object. Compared to ActiveFedora "thick" works that
    # encapsulate their own methods for save, update, delete, etc., Valkyrie uses "thin" models
    # where attribute validation and work create/update/delete are carried out through interactions
    # between multiple related modules. This service integrates the logic flow for creating a single
    # Valkyrie work, and should be used anywhere outside of a work's primary controller for creating
    # works.
    class CreateWorkService
      attr_reader :model, :params, :user, :work_attributes_key, :work_attributes, :files, :permissions_params, :form

      ##
      # Initialize the service specific to a model with attributes and depositing user.
      #
      # @param model [Constant, String] Model class or string version of model class name for work.
      # @param params [hash] The contextual parameters for the action; ApplicationController#params
      # @param user [User] the depositing user.
      # @param work_attributes_key [Symbol] the name of the key within the params that contains
      #                                     the work's attributes. Optional, will try to use model
      #                                     name if not present.
      def initialize(model:, params:, user:, work_attributes_key: nil, skip_index_related_works: false)
        @model = model
        @params = params
        @user = user
        @work_attributes_key = work_attributes_key

        @work_attributes = params.fetch(attributes_key, {})
        uploaded_file_ids = params.fetch(:uploaded_files, [])
        @files = Hyrax::UploadedFile.find(uploaded_file_ids) if uploaded_file_ids.present?
        @permissions_params = params.fetch(:permissions, [])
        @organization_id = params.fetch(:organization_id, nil)
        work = model_class.new
        @form = Hyrax::FormFactory.new.build(work, nil, nil)
        form.skip_index_related_works = true if skip_index_related_works
      end

      ##
      # Creates work. Will return result status object containing created work or failure messages.
      #
      # @return [Result] Result monad, responds to :success? boolean, :value_or with block to return
      #                 created work or execute block if not present, and :failure as tuple with
      #                 0) symbol error and 1) failure object with :full_messages method.
      def call
        if form.validate(work_attributes)
          transactions[transaction_name].with_step_args(**step_args).call(form)
        else
          errors = ( form.errors&.messages || {} ).map { |k, vs| vs.map { |v| "#{k} #{v}" } }.flatten.to_sentence
          raise "Error creating #{model} work: #{errors}"
        end
      end

      private

      def model_class
        model.is_a?(String) ? model.constantize : model
      end

      def attributes_key
        work_attributes_key.nil? ? model_class.to_s.underscore.to_sym : work_attributes_key
      end

      def transactions
        Hyrax::Transactions::Container
      end

      def transaction_name
        case model_class.to_s
        when 'TaxonomyResource'
          'taxonomy_change_set.create_work'
        when 'DeviceResource'
          'device_change_set.create_work'
        when 'ImagingEventResource'
          'change_set.create_work'
        else
          raise "Unpermitted work type #{model_class.to_s}"
        end
      end

      def step_args
        case model_class.to_s
        when 'TaxonomyResource'
          {
            'change_set.set_user_as_depositor' => { user: user },
            'work_resource.change_depositor' => { user: ::User.find_by_user_key(form.on_behalf_of) },
            'work_resource.save_acl' => { permissions_params: permissions_params }
          }
        when 'DeviceResource'
          {
            'device_change_set.set_organization_id' => { organization_id: @organization_id },
            'change_set.set_user_as_depositor' => { user: user },
            'work_resource.change_depositor' => { user: ::User.find_by_user_key(form.on_behalf_of) },
            'work_resource.save_acl' => { permissions_params: permissions_params }
          }
        when 'ImagingEventResource'
          {
            'change_set.set_user_as_depositor' => { user: user },
            'work_resource.save_acl' => { permissions_params: permissions_params }
          }
        else
          raise "Unpermitted work type #{model_class.to_s}"
        end
      end
    end
  end
end