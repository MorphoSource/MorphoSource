# Generated via
#  `rails generate hyrax:work Media`
module Hyrax
  # Generated form for Media
  class MediaForm < Hyrax::Forms::WorkForm
    self.model_class = ::Media
    include Morphosource::FormMethods
    include ChildCreateButton
    include SingleValuedForm

    class_attribute :single_value_fields, :permissions_terms

    delegate :tags=, :tags, to: :model

    # Customizing field terms

    self.terms = [
      :media_type,
      :x_spacing,
      :y_spacing,
      :z_spacing,
      :slice_thickness,
      :scale_bar,
      :unit,
      :map_type,
      :series_type,
      :identifier,
      :related_url,
      :part,
      :short_description,
      :side,
      :orientation,
      :description,
      :keyword,
      :identifier,
      :related_url,
      :creator,
      :date_created,
      :publisher,
      :representative_id,
      :thumbnail_id,
      :rendering_ids,
      :files,
      :visibility_during_embargo,
      :embargo_release_date,
      :visibility_after_embargo,
      :visibility_during_lease,
      :lease_expiration_date,
      :visibility_after_lease,
      :visibility,
      :ordered_member_ids,
      :in_works_ids,
      :member_of_collection_ids,
      :admin_set_id,
      # permissions
      :download_reviewer,
      :agreement_uri,
      :license,
      :rights_statement,
      :terms_of_use,
      :permits_commercial_use,
      :permits_3d_use,
      :rights_holder,
      :funding,
      :publisher,
      :cite_as]

    self.required_fields = [:media_type]

    self.single_valued_fields = [:short_description, :media_type, :cite_as, :legacy_media_file_id, :legacy_media_group_id, :uuid, :ark, :doi, :available, :x_spacing, :y_spacing, :z_spacing, :slice_thickness, :series_type, :unit, :identifier, :related_url, :terms_of_use, :download_reviewer, :agreement_uri, :permits_3d_use, :permits_commercial_use]

    self.permissions_terms = [ :download_reviewer, :agreement_uri, :license, :rights_statement, :terms_of_use, :permits_commercial_use, :permits_3d_use, :rights_holder, :funding, :publisher, :cite_as]

    def other_terms
      secondary_terms - permissions_terms
    end

    def self.build_permitted_params
      super + [:tags]
    end

  end
end
