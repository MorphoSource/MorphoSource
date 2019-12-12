# Generated via
#  `rails generate hyrax:work ProcessingEvent`
module Hyrax
  class ProcessingEventPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :software, :processing_activity, to: :solr_document
  end
end
