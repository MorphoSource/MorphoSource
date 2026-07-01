module Morphosource
  module Dashboard
    module Collections
      class MediaListsController < Morphosource::Dashboard::CollectionsController
        skip_load_and_authorize_resource only: [:edit, :update, :new, :members, :create], instance_name: :media_list

        before_action :redirect_to_collection_type, only: []
        skip_before_action :authorize_contributor
        before_action :authorize_admin, only: [:mint_doi]
        before_action :check_for_doi, only: [:destroy]
        before_action :check_visibility_direction, only: [:update]
        before_action :strip_doi_protected_fields, only: [:update]
        before_action :add_doi_message, only: [:edit]

        self.presenter_class = Morphosource::Collections::MediaListPresenter

        self.form_class = Morphosource::Forms::Collections::MediaListForm

        def mint_doi
          begin
            doi = @collection.mint_doi(media_list_url(@collection))
            if doi.is_a?(Exception)
              flash[:error] = "DOI minting failed: #{doi.message}."
            elsif doi.nil? || doi.blank?
              flash[:error] = "DOI minting failed. Please check the logs for details."
            else
              flash[:notice] = "Successfully minted DOI: #{doi}"
            end
          rescue => e
            flash[:error] = "DOI minting failed: #{e.message}."
          end
          redirect_to media_list_edit_path(@collection)
        end

        private

          def collection_type
            Hyrax::CollectionType.find_by(title: "Media List")
          end
          alias :default_collection_type :collection_type

          def collection_class
            MediaList
          end

          # Params non-admin users may submit on DOI media lists — everything else is stripped.
          DOI_LOCKED_ALLOWED_PARAMS = %w[visibility].freeze

          def check_for_doi
            return if current_user.admin?

            if @collection.doi.present?
              flash[:error] = t('morphosource.dashboard.collections.media_list.edit.doi_warning')
              redirect_to media_list_edit_path(@collection) and return
            end
          end

          # Blocks non-admin users from moving a public DOI list to any non-public visibility.
          # Checks against VISIBILITY_TEXT_VALUE_PUBLIC ('open') rather than a specific target
          # value so crafted requests with e.g. 'authenticated' are also rejected.
          def check_visibility_direction
            return if current_user.admin?
            return unless @collection.doi.present?
            public_value = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
            return unless @collection.visibility == public_value &&
                          params.dig(:media_list, :visibility) != public_value
            flash[:error] = t('morphosource.dashboard.collections.media_list.edit.doi_visibility_error')
            redirect_to media_list_edit_path(@collection)
          end

          # Strips all params except visibility for non-admin users on DOI media lists,
          # so a crafted request cannot modify other fields.
          def strip_doi_protected_fields
            return if current_user.admin?
            return unless @collection.doi.present?
            return unless params[:media_list].present?
            params[:media_list].slice!(*DOI_LOCKED_ALLOWED_PARAMS)
          end

          def add_doi_message
            return if current_user.admin?
            return unless @collection.doi.present?
            flash.now[:alert] = t('morphosource.dashboard.collections.media_list.edit.doi_message')
          end

      end
    end
  end
end
