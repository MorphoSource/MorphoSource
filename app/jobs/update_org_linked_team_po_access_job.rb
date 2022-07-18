class UpdateOrgLinkedTeamPoAccessJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_fast_queue_name

  def perform(team)
    org_id = team.organization&.id
    if org_id.present?
      qry = "organization_id_ssim:#{org_id} AND (has_model_ssim:BiologicalSpecimen OR has_model_ssim:CulturalHeritageObject)"
      result = ActiveFedora::SolrService.query(qry, rows: 999999)
      puts "#{result.count} physical objects found for org #{org_id}..."
byebug
      result.each do |hit|
        o = ActiveFedora::Base.find(hit.id)
        if o.present? and (o.class == BiologicalSpecimen or o.class == CulturalHeritageObject)
          puts "Updating physical object #{o.id} ..."
          UpdateOrgLinkedTeamPoEachAccessJob.perform_now(o, team.id)
        else
          puts "object #{o.id} not found"
        end
      end
    end
  end

end
