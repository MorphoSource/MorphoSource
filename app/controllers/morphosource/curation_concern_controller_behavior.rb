module Morphosource
  # Include in work controller before Hyrax::WorksControllerBehavior
  # Pre-empts CanCan load_resource to redirect to resource not found page
  module CurationConcernControllerBehavior
    extend ActiveSupport::Concern

    included do
      before_action :find_curation_concern, only: [:showcase, :edit]
    end

    private

    # Manually load resource to handle Ldp::Gone errors
    def find_curation_concern
      begin
        @curation_concern = Media.find(params[:id])
      rescue Ldp::Gone => e
        render 'not_found', locals: { resource_type: _curation_concern_type.to_s } and return
      end
    end
  end
end