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
      solr_doc['file_set_formats_tesim'] = object.file_set_formats
      solr_doc['fileset_accessibility_ssim'] = object.fileset_accessibility
      solr_doc['download_access_group_ssim'] = object.download_groups
      solr_doc['download_access_person_ssim'] = object.download_users
      solr_doc['owner_ssim'] = object.owner
      solr_doc['user_with_ownership_ssi'] = object.user_with_ownership
      solr_doc['user_with_ownership_name_tesim'] = User.find_by_user_key(object.user_with_ownership)&.name_and_email
      solr_doc['depositor_name_tesim'] = User.find_by_user_key(object.depositor)&.name_and_email
      solr_doc['download_reviewer_ssim'] = object.download_reviewer
      solr_doc['ark_ssim'] = object.ark
      solr_doc['doi_ssim'] = object.doi

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

      solr_doc['media_parent_id_ssim'] = object.media_parent&.id

      physical_objects = object.physical_objects

      if physical_objects.present? && are_physical_objects(physical_objects)
        physical_object_id = physical_objects.map(&:id)
        physical_object_title = physical_objects.map { |po| po.title&.first }.compact
        institution_code = physical_objects.map { |po| po.institution_code&.first }.compact
        collection_code = physical_objects.map { |po| po.collection_code&.first }.compact
        catalog_number = physical_objects.map { |po| po.catalog_number&.first }.compact

        physical_object_type = physical_objects.first.specimen? ? "Biological Specimen" : "Cultural Heritage Object"
        types = physical_objects.map(&:class).uniq
        if types == [CulturalHeritageObject]
          taxonomy_titles = nil
        elsif types == [BiologicalSpecimen]
          taxonomy_titles = physical_objects.map(&:taxonomies_titles).flatten
          occurrence_id = physical_objects.map { |po| po.occurrence_id&.first }.compact 
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
        institution_code = nil
        collection_code = nil
        catalog_number = nil
        occurrence_id = nil
      end

      # add physical object facet
      solr_doc['media_physical_object_type_tesim'] = physical_object_type
      # TODO: Delete _sim once media are reindexed w/ssim and catalog controller updated
      solr_doc['media_physical_object_type_sim'] = physical_object_type
      solr_doc['media_physical_object_type_ssim'] = physical_object_type
      # physical_object fields
      solr_doc['physical_object_id_ssim'] = physical_object_id
      solr_doc['physical_object_id_tesim'] = physical_object_id
      solr_doc['physical_object_title_ssim'] = physical_object_title
      solr_doc['physical_object_title_tesim'] = physical_object_title
      solr_doc['institution_code_ssim'] = institution_code
      solr_doc['institution_code_tesim'] = institution_code
      solr_doc['collection_code_tesim'] = collection_code
      solr_doc['collection_code_ssim'] = collection_code
      solr_doc['catalog_number_tesim'] = catalog_number
      solr_doc['catalog_number_ssim'] = catalog_number
      solr_doc['occurrence_id_tesim'] = occurrence_id
      solr_doc['occurrence_id_ssim'] = occurrence_id

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

      pub_status = publication_status
      solr_doc['publication_status_ssi'] = pub_status

      ie = object.imaging_event
      solr_doc['imaging_event_id_tesim'] = ie&.id

      device = ie&.device
      device_title = "#{device&.creator&.first} #{device&.title&.first}"
      solr_doc['media_device_tesim'] = device_title
      solr_doc['media_device_ssim'] = device_title
      solr_doc['media_device_id_tesim'] = device&.id
      solr_doc['media_device_id_ssim'] = device&.id
      facility_org = device&.organization
      facility_org_title = facility_org&.title&.first
      solr_doc['media_device_facility_organization_tesim'] = facility_org_title
      solr_doc['media_device_facility_organization_ssim'] = facility_org_title
      solr_doc['media_device_facility_organization_id_tesim'] = facility_org&.id
      solr_doc['media_device_facility_organization_id_ssim'] = facility_org&.id

      # sorting fields
      solr_doc['part_si'] = object.part&.first&.downcase
      solr_doc['physical_object_title_si'] = physical_object_title&.first&.downcase
      solr_doc['taxonomy_si'] = taxonomy_titles&.first&.downcase
      solr_doc['human_readable_media_type_si'] = mt&.first&.downcase
      solr_doc['publication_status_si'] = pub_status&.downcase
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

  def are_physical_objects(works)
    works.all? do |w|
      if w.respond_to?(:physical_object?) && w.physical_object?
        true
      else
        raise "Work #{w.id} is supposed to be a physical object, but is actually class #{w.class}"
      end
    end
  end
end
