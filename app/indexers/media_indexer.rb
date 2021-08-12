# Generated via
#  `rails generate hyrax:work Media`
class MediaIndexer < Morphosource::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  self.thumbnail_path_service = Morphosource::MediaThumbnailPathService

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['file_set_visibilities_ssim'] = object.file_set_visibilities
      solr_doc['fileset_accessibility_ssim'] = object.fileset_accessibility
      solr_doc['download_access_group_ssim'] = object.download_groups
      solr_doc['download_access_person_ssim'] = object.download_users
      solr_doc['owner_ssim'] = object.owner
      solr_doc['user_with_ownership_ssi'] = object.user_with_ownership
      solr_doc['download_reviewer_ssim'] = object.download_reviewer
      # add media type facet
      mt = object.human_readable_media_type
      solr_doc['human_readable_media_type_tesim'] = mt
      # TODO: Delete _sim once media are reindexed w/ssim and catalog controller updated
      solr_doc['human_readable_media_type_sim'] = mt
      solr_doc['human_readable_media_type_ssim'] = mt
      # add modality facet
      modality = object.modality
      solr_doc['media_modality_tesim'] = modality
      # TODO: Delete _sim once media are reindexed w/ssim and catalog controller updated
      solr_doc['media_modality_sim'] = modality
      solr_doc['media_modality_ssim'] = modality

      # data processing for subsequent fields
      physical_objects = object.physical_objects

      if physical_objects.present?
        physical_object_id = physical_objects.map(&:id)
        physical_object_title = physical_objects.map { |po| po.title&.first }.compact
        physical_object_type = physical_objects.first.specimen? ? "Biological Specimen" : "Cultural Heritage Object"
        types = physical_objects.map(&:class).uniq
        if types == [CulturalHeritageObject]
          taxonomy_titles = nil
        elsif types == [BiologicalSpecimen]
          taxonomy_titles = physical_objects.map(&:taxonomies_titles).flatten
        else
          taxonomy_titles = []
          physical_objects.each do |object|
            if object.specimen?
              taxonomy_titles += object.taxonomies_titles
            end
          end
        end

        @organizations ||= organizations

        if @organizations.present?
          organization_titles = @organizations.map{ |o| o.title.first }
          organization_id = @organizations.map{ |o| o.id }
        else
          organization_titles = nil
          organization_id = nil
        end
      else
        physical_object_type = nil
        physical_object_title = nil
        physical_object_id = nil
        taxonomy_titles = nil
        organization_titles = nil
        organization_id = nil
      end

      # add physical object facet
      solr_doc['media_physical_object_type_tesim'] = physical_object_type
      # TODO: Delete _sim once media are reindexed w/ssim and catalog controller updated
      solr_doc['media_physical_object_type_sim'] = physical_object_type
      solr_doc['media_physical_object_type_ssim'] = physical_object_type
      # physical_object_ids and titles
      solr_doc['physical_object_id_ssim'] = physical_object_id
      solr_doc['physical_object_id_tesim'] = physical_object_id
      solr_doc['physical_object_title_ssim'] = physical_object_title
      solr_doc['physical_object_title_tesim'] = physical_object_title

      # add taxonomies
      solr_doc['taxonomy_tesim'] = taxonomy_titles
      solr_doc['taxonomy_ssim'] = taxonomy_titles

      # add organization facet
      solr_doc['media_organization_tesim'] = organization_titles
      solr_doc['media_organization_ssim'] = organization_titles
      # TODO: Delete _sim once media are reindexed w/ssim and catalog controller updated
      solr_doc['media_organization_sim'] = organization_titles
      solr_doc['media_organization_id_ssim'] = organization_id
      solr_doc['media_organization_id_tesim'] = organization_id

      # add public collection membership facet
      solr_doc['member_of_public_collection_ids_ssim'] = object.member_of_public_collection_ids

      # team
      @team_ids = object.member_of_team_ids
      solr_doc['member_of_team_ids_ssim'] = @team_ids
      # project
      @project_ids = object.member_of_project_ids
      solr_doc['member_of_project_ids_ssim'] = @project_ids

      solr_doc['publication_status_ssi'] = publication_status

      # related media ids
      ie = object.imaging_event
      solr_doc['imaging_event_id_tesim'] = ie&.id

      facility_org = ie&.device&.organization
      facility_org_title = facility_org&.title&.first
      solr_doc['media_device_facility_organization_tesim'] = facility_org_title
      solr_doc['media_device_facility_organization_ssim'] = facility_org_title
      solr_doc['media_device_facility_organization_id_tesim'] = facility_org&.id
      solr_doc['media_device_facility_organization_id_ssim'] = facility_org&.id
      # origin of media for org-linked teams
      # populates facet used only on the linked team
      solr_doc['org_linked_team_origin_ssim'] = linked_team_origin
   end
  end

  def publication_status
    fa = object.fileset_accessibility
    if fa == ["open"]
      "Open Download"
    elsif fa == ["private"]
      "Private"
    elsif fa == ["restricted_download"]
      "Restricted Download"
    end
  end

  def organizations
    organizations = object.physical_objects.each_with_object([]) do |obj, orgs|
      obj.organizations.each { |org| orgs << org }
    end
    organizations.uniq
  end

  # This populates the 'origin/intersections' facet on linked teams
  # Facet may not be accurate in edge cases (for example, a media is added as a member of its organization's linked team, and also added as a member of a second linked team)

  # TODO: It might be better to move this logic to the NestingIndexAdapter: https://github.com/samvera/hyrax/blob/b034218b89dde7df534e32d1e5ade9161e129a1d/app/services/hyrax/adapters/nesting_index_adapter.rb to streamline checking of whether the project is nested within a team.
  def linked_team_origin
    @team_ids ||= object.member_of_team_ids
    @project_ids ||= object.member_of_project_ids
    @organizations ||= organizations
    return if @team_ids.blank? && @project_ids.blank? && @organizations.blank?

    # assumes that the media belongs to one organization
    linked_team_id = @organizations&.first&.team_id&.first

    values = []

    if @team_ids.present?
      if @team_ids.include? linked_team_id
        values << 'Team and Organization' << 'Team' << 'Organization'
      else
        values << 'Team Only' << 'Team'
      end
    elsif linked_team_id.present?
      if @project_ids.present? && project_parent_ids.include?(linked_team_id)
        values << 'Team and Organization' << 'Team' << 'Organization'
      else
        values << 'Organization Only' << 'Organization'
      end
    elsif @project_ids.present?
      values << 'Team Only' << 'Team'
    end
<<<<<<< HEAD
    values
  end

  def project_parent_ids
    Morphosource::SolrService.new.get_docs('',{fq: "(id:(#{@project_ids.join(' OR ')}))", fl:"nesting_collection__parent_ids_ssim"}).map{|d| d["nesting_collection__parent_ids_ssim"]}.flatten.compact.uniq
  end

  def linked_team_member_of_team_ids
    @team_ids ||= object.member_of_team_ids

    linked_team_id = @organizations&.first&.team_id&.first

    if linked_team_id.blank? || @team_ids.include?(linked_team_id)
      @team_ids
    else
      @team_ids + ['orglinked']
    end

=======
>>>>>>> b19d8ce0... wip
  end
end
