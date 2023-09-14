# require 'displays_mesh'

module Hyrax
  class MediaFileSetPresenter < Hyrax::MsFileSetPresenter
    include DisplaysMesh
    include DisplaysVolume

    delegate :mesh?, :volume?, to: :solr_document
    
  end
end
