module Morphosource
  module Users
    class ManagedMediaSearchBuilder < Morphosource::Catalog::MediaCatalogSearchBuilder
      # returns media managed by @user viewable by @current_user

      self.default_processor_chain += [:filter_by_managing_user]

      def initialize(scope)
        @current_ability = scope.current_ability
        @user ||= (scope.user || scope.current_ability.current_user)
        super
      end

      def current_ability
        @current_ability
      end

      def filter_by_managing_user(solr_parameters)
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] << "{!terms f=user_with_ownership_ssi}#{@user.ms_id}"
      end

      def blacklight_config
        MediaCatalogController.blacklight_config
      end

      private

        def models
          [::Media]
        end
    end
  end
end