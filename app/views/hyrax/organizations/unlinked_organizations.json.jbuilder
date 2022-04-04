# frozen_string_literal: true
# populates the unlinked organizations search box on the team edit page
# if institution name is present, text = "Institution name, Organization title"
# otherwise, text = "Organization title"
json.orgs @orgs do |org|
  if org[:institution_name_tesim].present?
    json.text org[:institution_name_tesim].first + ', ' + org[:title_tesim].first
  else
    json.text org[:title_tesim].first
  end
  json.id org.id
end
