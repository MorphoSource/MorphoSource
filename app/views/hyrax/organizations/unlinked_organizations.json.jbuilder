# frozen_string_literal: true
# populates the unlinked organizations search box on the team edit page
json.orgs @orgs do |org|
  json.text org[:title_tesim].first
  json.id org.id
end
