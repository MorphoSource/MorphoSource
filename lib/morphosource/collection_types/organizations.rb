module Morphosource
  module CollectionTypes
    module Organizations

      # Settings used by morphosource.rake when creating Organization collection type
      SETTINGS = {
        title: 'Organization',
        description: 'Facilitates management of objects, devices, and media for affiliated users.',
        machine_id: 'organization',
        nestable: true,
        discoverable: true,
        sharable: true,
        allow_multiple_membership: true,
        require_membership: false,
        assigns_workflow: false,
        assigns_visibility: false,
        share_applies_to_new_works: true,
        brandable: true,
        badge_color: '#329a43'
      }

    end
  end
end