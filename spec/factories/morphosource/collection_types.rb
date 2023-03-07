FactoryBot.define do

  factory :media_list_collection_type, class: Hyrax::CollectionType do
    title { "Media List" }
    description { "Assortment of media records. Media records can belong to multiple media lists. Multiple users can manage media lists." }
    machine_id { "media_list" }
    nestable { false }
    discoverable { true }
    sharable { true }
    allow_multiple_membership { true }
    require_membership { false }
    assigns_workflow { false }
    assigns_visibility { false }
    share_applies_to_new_works { false }
    brandable { true }
    badge_color { "#" }
  end

  factory :project_collection_type, class: Hyrax::CollectionType do
    title { "Project" }
    description { "Assortment of media and physical object records. Media and physical object records can belong to multiple projects. Multiple users or teams can manage projects." }
    machine_id { "project" }
    nestable { true }
    discoverable { true }
    sharable { true }
    allow_multiple_membership { true }
    require_membership { false }
    assigns_workflow { false }
    assigns_visibility { true }
    share_applies_to_new_works { true }
    brandable { true }
    badge_color { "#003880" }
  end

  factory :team_collection_type, class: Hyrax::CollectionType do
    title { "Team" }
    description { "Group of users belonging to the same institution, organization, department, collection, or lab. Teams can manage projects collectively." }
    machine_id { "team" }
    nestable { true }
    discoverable { true }
    sharable { true }
    allow_multiple_membership { true }
    require_membership { false }
    assigns_workflow { false }
    assigns_visibility { true }
    share_applies_to_new_works { true }
    brandable { true }
    badge_color { "#FF861F" }
  end

  factory :sequential_section_list_collection_type, class: Hyrax::CollectionType do
    title { "Sequential Section List" }
    description { "Assortment of media records created from a single object. Multiple users can manage sequential section lists." }
    machine_id { "sequential_section_list" }
    nestable { false }
    discoverable { true }
    sharable { true }
    allow_multiple_membership { true }
    require_membership { false }
    assigns_workflow { false }
    assigns_visibility { false }
    share_applies_to_new_works { false }
    brandable { true }
    badge_color { "#" }
  end

end