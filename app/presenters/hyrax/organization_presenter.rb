# Generated via
#  `rails generate hyrax:work Organization`
module Hyrax
  class OrganizationPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :organization_type, :institution_name, :institution_code, :collection_code, :recordset_id, :address, :city, :state_province, :country, :contact_person, :team_id, to: :solr_document
  end
end
