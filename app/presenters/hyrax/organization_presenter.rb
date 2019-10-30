# Generated via
#  `rails generate hyrax:work Organization`
module Hyrax
  class OrganizationPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :organization_code, :address, :city, :state_province, :country, to: :solr_document
  end
end
