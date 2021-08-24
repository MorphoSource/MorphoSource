class UpdateMediaMetadataJob < ApplicationJob

  queue_as Hyrax.config.update_slow_queue_name

  def perform(media_attributes)
  	if Media.exists?(media_attributes[:id]&.first)
  		media = Media.find(media_attributes[:id]&.first)
  		media_properties.each do |p|
        if media_attributes[p].present? && media[p] != media_attributes[p]
          media[p] = media_attributes[p]
        end
  		end
  		media.save!
  	end
  end

  def media_properties
    [ 
      :media_type, :short_description, :side, :series_type, :part, :orientation, 
      :legacy_media_file_id, :legacy_media_group_id, :ark, :doi, 
      :x_spacing, :y_spacing, :z_spacing, :slice_thickness, :download_reviewer, 
      :morphosource_use_agreement_type, :required_archival_of_published_derivatives, 
      :permits_commercial_use, :permits_3d_use, :rights_holder, :funding, 
      :cite_as, :description, :license, :rights_statement
    ]
  end
end