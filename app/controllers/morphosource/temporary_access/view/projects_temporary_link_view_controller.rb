module Morphosource
  module TemporaryAccess
    module View
      class ProjectsTemporaryLinkViewController < Morphosource::Collections::ProjectsController
        include TemporaryAccessViewControllerBehavior
        include CollectionsTemporaryLinkViewControllerBehavior

        before_action :load_temporary_access_link,
          :authorize_temporary_access_link,
          :load_curation_concern,
          :authorize_curation_concern,
          :set_authorization_cookie, only: :show
      end
    end
  end
end