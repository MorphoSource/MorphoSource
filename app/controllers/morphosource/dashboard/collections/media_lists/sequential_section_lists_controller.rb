module Morphosource
  module Dashboard
    module Collections
      module MediaLists
        class SequentialSectionListsController < Morphosource::Dashboard::Collections::MediaListsController

          skip_load_and_authorize_resource only: [:edit, :update, :new, :members, :create], instance_name: :sequential_section_list

          before_action :redirect_to_collection_type, only: []
          before_action :build_breadcrumbs, only: []
          before_action :load_collection

          self.presenter_class = Morphosource::Collections::MediaLists::SequentialSectionListPresenter

          self.form_class = Morphosource::Forms::Collections::MediaLists::SequentialSectionListForm

          private

            def default_collection_type
              Hyrax::CollectionType.find_by(title: "Sequential Section List")
            end

            def collection_class
              SequentialSectionList
            end

            def collection_params
              form_class.model_attributes(params[:sequential_section_list])
            end

            def update_thumbnail
              media = Media.where(id: params[:sequential_section_list][:representative_id]).first
              @collection.thumbnail_id = media.try(:thumbnail_id)
            end

            def process_member_changes
              case params[:sequential_section_list][:members]
              when 'add' then add_members_to_collection
              when 'remove' then remove_members_from_collection
              when 'move' then move_members_between_collections
              end
            end
        end
      end
    end
  end
end
