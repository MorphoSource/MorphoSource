module Morphosource
  module Users
    class ManagedCollectionsSearchBuilder < Morphosource::Catalog::CollectionsCatalogSearchBuilder

      self.default_processor_chain += [:filter_by_managing_user]

      def filter_by_managing_user(solr_parameters)
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] << "{!terms f=edit_access_group_ssim}#{@user.manager_groups.join(',')}"
      end

      private

        def models
          [::Collection]
        end
    end
  end
end