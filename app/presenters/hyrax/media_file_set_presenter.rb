# require 'displays_mesh'

module Hyrax
  class MediaFileSetPresenter < Hyrax::MsFileSetPresenter
    include DisplaysMesh
    include DisplaysVolume

    delegate :mesh?, to: :solr_document
    delegate :volume?, to: :solr_document
    
  end
end
