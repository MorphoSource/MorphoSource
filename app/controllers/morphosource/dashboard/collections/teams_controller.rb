module Morphosource
  module Dashboard
    module Collections
      class TeamsController < Morphosource::Dashboard::CollectionsController

        skip_load_and_authorize_resource only: [:edit, :update], instance_name: :collection

        before_action :redirect_to_collection_type, only: []
        before_action :load_collection

        self.presenter_class = Morphosource::Collections::TeamPresenter

        def edit
          byebug
          @projects = member_subcollections
          byebug
          super
        end

        private

          def member_subcollections
            docs = Morphosource::SolrService.new.get_docs("has_model_ssim:Collection AND member_of_collection_ids_ssim:#{@collection.id}")
            docs.each do |doc|
              media_count = Morphosource::SolrService.new.get_docs("member_of_collection_ids_ssim:#{doc['id']}").count
              doc.merge!({"media_count" => media_count})
            end
          end

      end
    end
  end
end
