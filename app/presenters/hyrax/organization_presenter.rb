# Generated via
#  `rails generate hyrax:work Organization`
module Hyrax
  class OrganizationPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :institution_code, :address, :city, :state_province, :country, :team_id, to: :solr_document
  end
end
