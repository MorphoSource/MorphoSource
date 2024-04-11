require 'rails_helper'

RSpec.describe Morphosource::Forms::Collections::OrganizationCollectionForm do
  subject               { described_class }

  let(:collection_form) { Hyrax::Forms::CollectionForm }

  let(:organization_terms) do
    [:address,
     :agreement_uri,
     :city,
     :collection_code,
     :collection_type,
     :contact_person,
     :country,
     :data_manager,
     :download_permission,
     :download_reviewer,
     :institution_code,
     :institution_name,
     :license_blank,
     :media_ownership_transfer,
     :morphosource_use_agreement_type,
     :organization_type,
     :permissions_enforcement_mode,
     :permits_3d_use,
     :permits_commercial_use,
     :postal_code,
     :preview_mode,
     :recordset_id,
     :required_archival_of_published_derivatives,
     :rights_holder,
     :rights_holder_blank,
     :rights_statement,
     :rights_statement_blank,
     :state_province]
  end

  let(:organization_single_valued_fields) do
    [:address,
     :agreement_uri,
     :city,
     :copyright_blank,
     :country,
     :data_manager,
     :download_permission,
     :institution_name,
     :license,
     :license_blank,
     :media_ownership_transfer,
     :morphosource_use_agreement_type,
     :organization_type,
     :permissions_enforcement_mode,
     :permits_3d_use,
     :permits_commercial_use,
     :postal_code,
     :preview_mode,
     :required_archival_of_published_derivatives,
     :rights_holder_blank,
     :rights_statement,
     :rights_statement_blank,
     :state_province]
  end

  it "has expected metadata terms" do
    expect(subject.terms).to match_array(collection_form.terms + organization_terms)
  end

  it "has expected required metadata terms" do
    expect(subject.required_fields).to match_array(collection_form.required_fields)
  end

  it "has expected single valued metadata terms" do
    expect(subject.single_valued_fields).to match_array(collection_form.single_valued_fields + organization_single_valued_fields)
  end
end