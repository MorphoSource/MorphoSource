module Hyrax
  module Ability
    module CollectionAbility
      def collection_abilities # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        default_collection_models = [::Collection, Hyrax::PcdmCollection]

        if admin?
          default_collection_models.each do |collection_model|
            can :manage, collection_model
            can :manage_any, collection_model
            can :create_any, collection_model
            can :view_admin_show_any, collection_model
            can :create, collection_model
          end
          
          can :create, ::MediaList
          can :create, ::SequentialSectionList
          can :create, ::OrganizationCollection
          can :destroy, ::OrganizationCollection
        elsif contributor?
          default_collection_models.each do |collection_model|
            can :create_any, collection_model
            can :manage_any, collection_model if Hyrax::Collections::PermissionsService.can_manage_any_collection?(ability: self)
            can :view_admin_show_any, collection_model if Hyrax::Collections::PermissionsService.can_view_admin_show_for_any_collection?(ability: self)
            can :create, collection_model
            can [:edit, :update, :destroy], collection_model do |collection| # for test by solr_doc, see solr_document_ability.rb
              test_edit(collection.id)
            end

            # users can edit all works in a collection, but can't edit collection metadata or permissions
            can :edit_works, collection_model do |collection|
              Hyrax::Collections::PermissionsService.can_edit_collection_works?(ability: self, collection_id: collection.id)
            end

            can :deposit, collection_model do |collection|
              Hyrax::Collections::PermissionsService.can_deposit_in_collection?(ability: self, collection_id: collection.id)
            end

            can :view_admin_show, collection_model do |collection| # admin show page
              Hyrax::Collections::PermissionsService.can_view_admin_show_for_collection?(ability: self, collection_id: collection.id)
            end
          end

          can :create, ::MediaList
          can :create, ::SequentialSectionList

          can :deposit, SolrDocument do |solr_doc|
            Hyrax::Collections::PermissionsService.can_deposit_in_collection?(ability: self, collection_id: solr_doc.id) # checks collections and admin_sets
          end

          can :view_admin_show, SolrDocument do |solr_doc| # admin show page
            Hyrax::Collections::PermissionsService.can_view_admin_show_for_collection?(ability: self, collection_id: solr_doc.id) # checks collections and admin_sets
          end
        elsif registered_user?
          can :create, ::MediaList

          can [:edit, :update, :destroy], MediaList do |list| # for test by solr_doc, see solr_document_ability.rb
            test_edit(list.id)
          end

          cannot :create, ::SequentialSectionList

          # only admins can create organization collections
          cannot :create, ::OrganizationCollection
        end

        default_collection_models.each do |collection_model|
          # users can view and download all works in a collection, regardless of work publication status
          can :download_works, collection_model do |collection|
            Hyrax::Collections::PermissionsService.can_download_collection_works?(ability: self, collection_id: collection.id)
          end

          can :read, collection_model do |collection| # public show page  # for test by solr_doc, see solr_document_ability.rb
            test_read(collection.id)
          end
        end
      end
    end
  end
end
