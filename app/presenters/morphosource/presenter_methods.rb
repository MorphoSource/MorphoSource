module Morphosource
  module PresenterMethods
    include ActionView::Helpers::UrlHelper

    # Methods below used to parent works on a work's show page.

    def work
      ::ActiveFedora::Base.find(solr_document.id)
    end

    def work_id
      solr_document.id
    end

    # Methods below copied from rdr/dataset_presenter.rb
    # Adds "In Media, In Physical object," etc. to Relationships section of a work's show page.

    # Overrides 'Hyrax::WorkShowPresenter#grouped_presenters' to add in the presenters for works in which the current
    # work is nested
    def grouped_presenters(filtered_by: nil, except: nil)
      super.merge(grouped_work_presenters(filtered_by: filtered_by, except: except))
    end

    # modeled on '#grouped_presenters' in Hyrax::WorkShowPresenter, which returns presenters for the collections of
    # which the work is a member
    def grouped_work_presenters(filtered_by: nil, except: nil)
      grouped = in_work_presenters.group_by(&:model_name).transform_keys { |key| key.to_s.underscore }
      grouped.select! { |obj| obj.downcase == filtered_by } unless filtered_by.nil?
      grouped.except!(*except) unless except.nil?
      grouped || {}
    end

    # modeled on '#member_of_collection_presenters' in Hyrax::WorkShowPresenter
    def in_work_presenters
      Hyrax::PresenterFactory.build_for(ids: work.in_works_ids,
                                 presenter_class: Hyrax::WorkShowPresenter,
                                 presenter_args: presenter_factory_arguments)
    end

    # media cart method
    def works_in_cart
      current_ability.current_user.work_ids_in_cart
    end

    def downloaded_works
      current_ability.current_user.downloaded_work_ids
    end

    # physical objects showcase page methods
    def parent_organization
      organization_id = solr_document.organization_id&.first
      return nil unless organization_id.present? && Organization.exists?(organization_id)
      Organization.find(organization_id)
    end

    def parent_organization_id
       return '' unless parent_organization.present?
       parent_organization.id
    end

    def parent_organization_organization_type
       return '' unless parent_organization.present?
       parent_organization.organization_type&.first
    end

    def parent_organization_institution_name
       return '' unless parent_organization.present?
       parent_organization.institution_name&.first
    end

    def parent_organization_title
      return '' unless parent_organization.present?
      parent_organization.title&.first
    end

    def parent_organization_institution_code
      return [] unless parent_organization.present?
      parent_organization.institution_code
    end

    def parent_organization_collection_code
       return [] unless parent_organization.present?
       parent_organization.collection_code
    end

    def parent_organization_related_url
       return [] unless parent_organization.present?
       parent_organization.related_url
    end

    def parent_organization_address
       return '' unless parent_organization.present?
       parent_organization.address&.first
    end

    def parent_organization_city
       return '' unless parent_organization.present?
       parent_organization.city&.first
    end

    def parent_organization_state_province
       return '' unless parent_organization.present?
       parent_organization.state_province&.first
    end

    def parent_organization_postal_code
       return '' unless parent_organization.present?
       parent_organization.postal_code&.first
    end

    def parent_organization_country
       return '' unless parent_organization.present?
       parent_organization.country&.first
    end

    def parent_organization_contact_person
       return [] unless parent_organization.present?
       parent_organization.contact_person
    end

    def parent_organization_description
       return '' unless parent_organization.present?
       parent_organization.description&.first
    end

    def source_of_record
      if solr_document.idigbio_uuid.present?
        'iDigBio'
      else
        ''
      end
    end

    # this method is cloned from list_of_item_ids_to_display (for defaut view),
    # to get a list of media images for PO showpage
    def list_of_item_ids_to_display_for_showpage
      # get the media from
      # PO > IE > media
      # or
      # PO > IE > PE > media (media with absentee parent)
      child_ids = solr_document.member_ids
      imaging_events = ImagingEvent.where('id' => child_ids)
      media_ids = []
      if imaging_events.present?
        imaging_events.each do |imaging_event|
          child_ids = imaging_event.member_ids  # todo: do we need to handle more than one media work per imaging event?

          # check for absentee parent
          # PO > IE > PE > media (media with absentee parent)
          processing_events = ProcessingEvent.where('id' => child_ids)
          if processing_events.present?
            # todo: do we need to handle more than one PE here?
            processing_event_child_ids = processing_events.first.member_ids
            medias = Media.where('id' => processing_event_child_ids.first)
          else
            medias = Media.where('id' => child_ids)
          end

          # todo: do we need to handle more than one media here?
          media = medias.first
          if media.present?
            # add current media id, then add child media ids.
            # currently add up to 5 levels in the tree.  Later we should store the child medias in the work
            # so there is no need to traverse the tree
            media_ids << media.id
            media_ids << child_media_ids(media, 5, media_ids)
          end
        end # looping IE
      end
      media_ids.flatten.uniq
    end

    # displays number of media for physical objects in catalog search results
    def total_viewable_media
      ActiveFedora::Base.where("physical_object_id_tesim:#{id}").accessible_by(current_ability).count
    end

  end
end
