# Generated via
#  `rails generate hyrax:work Media`
require 'rails_helper'

RSpec.describe Hyrax::MediaForm do

  let(:terms)                 { [:media_type, :x_spacing, :y_spacing, :z_spacing, :slice_thickness, :scale_bar, :unit, :map_type, :series_type, :identifier, :related_url, :part, :short_description, :side, :orientation, :description, :keyword, :identifier, :related_url, :creator, :date_created, :publisher, :representative_id, :thumbnail_id, :rendering_ids, :files, :visibility_during_embargo, :embargo_release_date, :visibility_after_embargo, :visibility_during_lease, :lease_expiration_date, :visibility_after_lease, :visibility, :ordered_member_ids, :in_works_ids, :member_of_collection_ids, :admin_set_id, :download_reviewer, :agreement_uri, :license, :rights_statement, :terms_of_use, :permits_commercial_use, :permits_3d_use, :rights_holder, :funding, :publisher, :cite_as] }
  let(:required_fields)       { [:media_type] }
  let(:single_valued_fields)  { [:media_type, :cite_as, :legacy_media_file_id, :legacy_media_group_id, :uuid, :ark, :doi, :available, :x_spacing, :y_spacing, :z_spacing, :series_type, :short_description, :slice_thickness, :unit, :identifier, :related_url, :terms_of_use, :download_reviewer, :permits_3d_use, :permits_commercial_use] }
  let(:permissions_terms)     { [:download_reviewer, :agreement_uri, :license, :rights_statement, :terms_of_use, :permits_commercial_use, :permits_3d_use, :rights_holder, :funding, :publisher, :cite_as] }
  let(:other_terms)           { [:x_spacing, :y_spacing, :z_spacing, :slice_thickness, :scale_bar, :unit, :map_type, :series_type, :identifier, :related_url, :part, :short_description, :side, :orientation, :description, :keyword, :identifier, :related_url, :creator, :date_created] }


  describe 'class attributes' do

    it 'has expected metadata terms' do
      expect(described_class.terms).to match_array(terms)
    end

    it 'has expected required metadata terms' do
      expect(described_class.required_fields).to match_array(required_fields)
    end

    it 'has expected single valued metadata terms' do
      expect(described_class.single_valued_fields).to match_array(single_valued_fields)
    end

    it 'has expected permissions terms' do
      expect(described_class.permissions_terms).to match_array(permissions_terms)
    end
  end

  describe '#other_terms' do
    let(:media)   { Media.new() }

    it 'has expected other terms' do
      expect(described_class.new(media, nil, nil).other_terms).to match_array(other_terms)
    end
  end

  describe '.build_permitted_params' do
    it 'includes tags' do
      expect(described_class.build_permitted_params).to include(:tags)
    end
  end
end
