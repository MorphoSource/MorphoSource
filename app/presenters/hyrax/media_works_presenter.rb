module Hyrax
  class MediaWorksPresenter # < CollectionPresenter
    #include MorphosourceHelper
    #include Morphosource::MediaWorksHelper

    attr_reader :search_form_url


    def initialize(current_user, current_ability, request = nil)
      @search_form_url = '' 
    end


    # Metadata Methods
#    delegate :title, :description, :creator, :contributor, :subject, :publisher, :keyword, :language, :embargo_release_date,
#             :lease_expiration_date, :license, :date_created, :resource_type, :based_near, :related_url, :identifier, :thumbnail_path,
#             :title_or_label, :collection_type_gid, :create_date, :modified_date, :visibility, :edit_groups, :edit_people,
#             :part, :media_type, 
#             to: :solr_document
#

  
  end
end
