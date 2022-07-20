class UpdateOrgLinkedTeamPoJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_fast_queue_name

  def perform(team, update)
    org_id = team.organization&.id
    puts "Team #{team.id} Org #{org_id}..."
    if org_id.present?
      qry = "media_organization_id_ssim:#{org_id} AND (has_model_ssim:Media)"
      org_media_result = ActiveFedora::SolrService.query(qry, rows: 999999)
      org_media_object_ids = org_media_result.map{|d| d["physical_object_id_ssim"].try(:first)}.compact.uniq
      count = 0
      org_media_object_ids.each do |id|
        begin
          o = ActiveFedora::Base.find(id)
          if o.present? and (o.class == BiologicalSpecimen or o.class == CulturalHeritageObject)
            puts "Updating physical object #{id} ..."
            UpdateOrgLinkedTeamPoAccessJob.perform_later(o, team.id) if update
            count += 1
          else
            puts "object #{id} not found"
          end
        rescue Exception => e
          puts "Exception with object #{id} (possibly object is gone)" 
        end
      end
      puts "Updated #{count} physical objects for Team #{team.id} Org #{org_id}"
    end
  end

end
