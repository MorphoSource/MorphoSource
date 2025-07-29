module Morphosource
  module Users
    class ManagedCollectionsSearchBuilder < Morphosource::Catalog::CollectionsCatalogSearchBuilder
      # returns the collections (Projects and Teams) managed by @user viewable by @current_user

      self.default_processor_chain += [:filter_by_managing_user]

      def initialize(scope)
        @current_ability = scope.current_ability
        @user = scope.current_ability.current_user
        super
      end

      def current_ability
        @current_ability
      end

      def filter_by_managing_user(solr_parameters)
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] << "{!terms f=edit_access_group_ssim}#{@user.manager_groups.join(',')}"
      end

      def blacklight_config
        CollectionsCatalogController.blacklight_config
      end

      private

        def models
          [::Collection]
        end
    end
  end
end