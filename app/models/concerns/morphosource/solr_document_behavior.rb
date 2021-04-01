module Morphosource
  module SolrDocumentBehavior
    extend ActiveSupport::Concern
    include Morphosource::Works::MimeTypes

    # displays the record source for specimens
    def object_record_source
      if idigbio_uuid
        ActionController::Base.helpers.link_to('iDigBio', idigbio_url)
      else
        'User Created'
      end
    end

    def idigbio_url
      if idigbio_uuid
        "https://www.idigbio.org/portal/records/#{idigbio_uuid.first}"
      else
        ""
      end
    end

    def collection_member_count
      Collection.find(id).group_member_count
    end
  end
end
