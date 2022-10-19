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

    def parent_organization_recordset_id
       return [] unless parent_organization.present?
       parent_organization.recordset_id.join(',')
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

    # displays number of media for physical objects in catalog search results
    def total_viewable_media
      ActiveFedora::Base.where("physical_object_id_tesim:#{id} AND has_model_ssim:Media").accessible_by(current_ability).count
    end

  end
end
