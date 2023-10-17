module Morphosource
  module Users
    class DepositedMediaSearchBuilder < Morphosource::Catalog::MediaCatalogSearchBuilder
      # returns the media deposited by @user viewable by @current_user

      self.default_processor_chain += [:filter_by_depositing_user]

      def initialize(scope)
        @current_ability = scope.current_ability
        @user = scope.user
        super
      end

      def current_ability
        @current_ability
      end

      def filter_by_depositing_user(solr_parameters)
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] << "{!terms f=depositor_ssim}#{@user.ms_id}"
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