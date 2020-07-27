module Morphosource
  module Dashboard
    class CollectionMembersController < Hyrax::Dashboard::CollectionMembersController
      before_action :filter_docs_with_read_access!, except: [:update_members]
      before_action :filter_docs_with_edit_access!, only: [:update_members]
      
    end
  end
end
