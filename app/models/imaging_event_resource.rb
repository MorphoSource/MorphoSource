# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource ImagingEventResource`
class ImagingEventResource < Hyrax::Work
  include Hyrax::Schema(:basic_metadata)
  include Hyrax::Schema(:imaging_event_resource)
  include Morphosource::ValkyrieWorkBehavior


end
