# require 'displays_mesh'

module Hyrax
  class MediaFileSetPresenter < Hyrax::MsFileSetPresenter
    include DisplaysMesh
    include DisplaysVolume

    delegate :archive?, :mesh?, :volume?, to: :solr_document
    
  end
end
