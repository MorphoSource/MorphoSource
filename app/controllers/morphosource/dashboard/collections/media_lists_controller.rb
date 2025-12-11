module Morphosource
  module Dashboard
    module Collections
      class MediaListsController < Morphosource::Dashboard::CollectionsController
        skip_load_and_authorize_resource only: [:edit, :update, :new, :members, :create], instance_name: :media_list

        before_action :redirect_to_collection_type, only: []
        skip_before_action :authorize_contributor
        before_action :authorize_admin, only: [:mint_doi]
        before_action :check_for_doi, only: [:update, :destroy]
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

          def check_for_doi
            return if current_user.admin?

            if @collection.doi.present?
              flash[:error] = t('morphosource.dashboard.collections.media_list.edit.doi_warning')
              redirect_to media_list_edit_path(@collection) and return
            end
          end

          def add_doi_message
            if @collection.doi.present?
              flash.now[:notice] = t('morphosource.dashboard.collections.media_list.edit.doi_message')
            end
          end

      end
    end
  end
end
