class UpdateOrgLinkedTeamMediaJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_fast_queue_name

  def perform(po_type_qs, team, update)
    org_id = team.organization&.id
    puts "Team #{team.id} Org #{org_id}..."
    if org_id.present?
      qry =  "media_organization_id_ssim:#{org_id} AND (has_model_ssim:Media)"
      if po_type_qs.present?
        qry += " AND media_physical_object_type_ssim:\"#{po_type_qs}\""
      end
      org_media_result = ActiveFedora::SolrService.query(qry, rows: 999999)
      count = 0
      org_media_result.each do |m|
        begin
          m = Media.find(m.id)
          if m.present? 
            puts "Updating media #{m.id} ..."
            UpdateOrgLinkedTeamMediaAccessJob.perform_later(m, team.id) if update
            count += 1
          else
            puts "media #{m.id} not found"
          end
        rescue Exception => e
          puts "Exception with media #{m.id} (possibly media is gone)" 
        end
      end
      puts "Updated #{count} media for Team #{team.id} Org #{org_id}"
    end
  end

end
