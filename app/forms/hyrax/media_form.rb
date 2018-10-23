# Generated via
#  `rails generate hyrax:work Media`
module Hyrax
  # Generated form for Media
  class MediaForm < Hyrax::Forms::WorkForm
    self.model_class = ::Media

    include SingleValuedForm

    class_attribute :single_value_fields

    # Customizing field terms

    self.terms = [:modality, :media_type, :x_spacing, :y_spacing, :z_spacing,
                    :scale_bar, :unit, :map_type,
                    :part, :side, :orientation,
                    :description, :keyword, :identifier, :related_url, :creator, :date_created,
                    :funding, :license, :rights_statement, :agreement_uri,
                    :rights_holder, :cite_as, :publisher,
                    :representative_id, :thumbnail_id, :rendering_ids, :files,
                    :visibility_during_embargo, :embargo_release_date, :visibility_after_embargo,
                    :visibility_during_lease, :lease_expiration_date, :visibility_after_lease,
                    :visibility, :ordered_member_ids, :in_works_ids,
                    :member_of_collection_ids, :admin_set_id]

    self.required_fields = [:modality, :media_type]

    self.single_valued_fields = [:media_type, :cite_as, :legacy_media_file_id, :legacy_media_group_id, :uuid, :ark, :doi, :available, :x_spacing, :y_spacing, :z_spacing, :unit]

  end
end
