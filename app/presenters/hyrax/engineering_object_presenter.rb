# Generated via
#  `rails generate hyrax:work EngineeringObject`
module Hyrax
  class EngineeringObjectPresenter < Hyrax::WorkShowPresenter

    delegate :desription, to: :solr_document

  end
end
