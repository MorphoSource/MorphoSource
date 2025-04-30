# require 'displays_mesh'

module Hyrax
  class MediaFileSetPresenter < Hyrax::MsFileSetPresenter
    delegate :archive?, :mesh?, :volume?, to: :solr_document
  end
end
