module Morphosource
  # Adds methods to add work to parent work
  module FormMethods
    include MorphosourceHelper

    delegate :work_parents_attributes=, :fileset_visibility, to: :model

    def self.included(base)
      base.extend(FormMethods)
    end

    # This code block is extending self.build_permitted_params from Hyrax::Forms::WorkForm
    # @return [Array] a list of parameters used by sanitize_params
    def build_permitted_params
      super + [
       :on_behalf_of,
       :version,
       :add_works_to_collection,
       :organization_institution,
       {
         based_near_attributes: [:id, :_destroy],
         member_of_collections_attributes: [:id, :_destroy],
         work_members_attributes: [:id, :_destroy],
         work_parents_attributes: [:id, :_destroy]
       }
      ]
    end

    # @return [NilClass]
    def find_parent_work; end

    # @return [NilClass]
    def find_organization; end

    # @return [NilClass]
    def select_device_id; end

    # @return [NilClass]
    def taxonomy_search; end

    def member_of_works_json(work_type=nil)
      parent_works = model.in_works
      # If a work is deposited as a child of another work, it will have a parent_id
      if @controller.params[:parent_id]
        parent_works << ::ActiveFedora::Base.find(@controller.params[:parent_id])
      end
      # filter by work type
      if work_type.present?
        parent_works = parent_works.select{ |item| item.class.to_s == work_type }
      end
      parent_works.map do |parent|
        {
          id: parent.id,
          label: parent.to_s,
          path: @controller.url_for(parent)
        }
      end.to_json
    end

    def member_of_devices_json(work_type=nil)
      parent_works = model.in_works
      # If a work is deposited as a child of another work, it will have a parent_id
      if @controller.params[:parent_id]
        parent_works << ::ActiveFedora::Base.find(@controller.params[:parent_id])
      end
      # filter by work type
      if work_type.present?
        parent_works = parent_works.select{ |item| item.class.to_s == work_type }
      end
      parent_works.map do |parent|
        {
          id: parent.id,
          label: parent.to_s,
          creator: parent.creator.first.to_s,
          modality: parent.modality.first.to_s,
          description: parent.description.first.to_s,
          organization_institution: organization_institution(parent.id)
        }
      end.to_json
    end

    def organization_institution(id)
        # get the device organization title and institution name for display
        organization_institution = ''
        organizations = Organization.where('member_ids_ssim' => id)
        if organizations.present?
          organization = organizations.first
          organization_institution = organization.title.first
          organization_institution += ' (' + organization.institution_name.first + ')' if organization.institution_name.present?
        end
        organization_institution
    end

    def member_of_organizations_json(work_type=nil)
      parent_works = model.in_works
      # If a work is deposited as a child of another work, it will have a parent_id
      if @controller.params[:parent_id]
        parent_works << ::ActiveFedora::Base.find(@controller.params[:parent_id])
      end
      # filter by work type
      if work_type.present?
        parent_works = parent_works.select{ |item| item.class.to_s == work_type }
      end
      parent_works.map do |parent|
        {
          id: parent.id,
          label: parent.to_s,
          organization_type: parent.organization_type.first.to_s,
          institution_name: parent.institution_name.first.to_s,
          institution_code: parent.institution_code.first.to_s,
          collection_code: parent.collection_code.first.to_s,
          recordset_id: parent.recordset_id.first.to_s,
          description: parent.description.first.to_s,
          related_url: parent.related_url.first.to_s,
          address: parent.address.first.to_s,
          city: parent.city.first.to_s,
          state_province: parent.state_province.first.to_s,
          postal_code: parent.postal_code.first.to_s,
          country: parent.country.first.to_s,
          contact_person: parent.contact_person.first.to_s,
          path: @controller.url_for(parent)
        }
      end.to_json
    end

    def member_of_biological_specimens_json(work_type=nil)
      parent_works = model.in_works
      # If a work is deposited as a child of another work, it will have a parent_id
      if @controller.params[:parent_id]
        parent_works << ::ActiveFedora::Base.find(@controller.params[:parent_id])
      end
      # filter by work type
      if work_type.present?
        parent_works = parent_works.select{ |item| item.class.to_s == work_type }
      end
      parent_works.map do |parent|
        {
          id: parent.id,
          label: parent.to_s,
          bibliographic_citation: parent.bibliographic_citation.first.to_s,
          catalog_number: parent.catalog_number.first.to_s,
          collection_code: parent.collection_code.first.to_s,
          canonical_taxonomy: parent.canonical_taxonomy.first.to_s,
          institution_code: parent.institution_code.first.to_s,
          latitude: parent.latitude.first.to_s,
          longitude: parent.longitude.first.to_s,
          numeric_time: parent.numeric_time.first.to_s,
          original_location: parent.original_location.first.to_s,
          periodic_time: parent.periodic_time.first.to_s,
          vouchered: parent.vouchered.first.to_s,
          idigbio_recordset_id: parent.idigbio_recordset_id.first.to_s,
          idigbio_uuid: parent.idigbio_uuid.first.to_s,
          is_type_specimen: parent.is_type_specimen.first.to_s,
          occurrence_id: parent.occurrence_id.first.to_s,
          source_of_record: source_of_record(parent.idigbio_uuid, parent.idigbio_recordset_id),
          sex: parent.sex.first.to_s
        }
      end.to_json
    end

    def member_of_cultural_heritage_objects_json(work_type=nil)
      parent_works = model.in_works
      # If a work is deposited as a child of another work, it will have a parent_id
      if @controller.params[:parent_id]
        parent_works << ::ActiveFedora::Base.find(@controller.params[:parent_id])
      end
      # filter by work type
      if work_type.present?
        parent_works = parent_works.select{ |item| item.class.to_s == work_type }
      end
      parent_works.map do |parent|
        {
          id: parent.id,
          label: parent.to_s,
          bibliographic_citation: parent.bibliographic_citation.first.to_s,
          catalog_number: parent.catalog_number.first.to_s,
          collection_code: parent.collection_code.first.to_s,
          institution_code: parent.institution_code.first.to_s,
          latitude: parent.latitude.first.to_s,
          longitude: parent.longitude.first.to_s,
          numeric_time: parent.numeric_time.first.to_s,
          original_location: parent.original_location.first.to_s,
          periodic_time: parent.periodic_time.first.to_s,
          vouchered: parent.vouchered.first.to_s,
          cho_type: parent.cho_type.first.to_s,
          material: parent.material.first.to_s,
          short_title: parent.short_title.first.to_s
        }
      end.to_json
    end

    def member_of_taxonomies_json(work_type=nil)
      parent_works = model.in_works
      # If a work is deposited as a child of another work, it will have a parent_id
      if @controller.params[:parent_id]
        parent_works << ::ActiveFedora::Base.find(@controller.params[:parent_id])
      end
      # filter by work type
      if work_type.present?
        parent_works = parent_works.select{ |item| item.class.to_s == work_type }
      end
      parent_works.map do |parent|
        {
          id: parent.id,
          label: parent.to_s,
          taxonomy_domain: parent.taxonomy_domain.first.to_s,
          taxonomy_kingdom: parent.taxonomy_kingdom.first.to_s,
          taxonomy_phylum: parent.taxonomy_phylum.first.to_s,
          taxonomy_superclass: parent.taxonomy_superclass.first.to_s,
          taxonomy_class: parent.taxonomy_class.first.to_s,
          taxonomy_subclass: parent.taxonomy_subclass.first.to_s,
          taxonomy_superorder: parent.taxonomy_superorder.first.to_s,
          taxonomy_order: parent.taxonomy_order.first.to_s,
          taxonomy_suborder: parent.taxonomy_suborder.first.to_s,
          taxonomy_superfamily: parent.taxonomy_superfamily.first.to_s,
          taxonomy_family: parent.taxonomy_family.first.to_s,
          taxonomy_subfamily: parent.taxonomy_subfamily.first.to_s,
          taxonomy_tribe: parent.taxonomy_tribe.first.to_s,
          taxonomy_genus: parent.taxonomy_genus.first.to_s,
          taxonomy_subgenus: parent.taxonomy_subgenus.first.to_s,
          taxonomy_species: parent.taxonomy_species.first.to_s,
          taxonomy_subspecies: parent.taxonomy_subspecies.first.to_s,
          gbif_key: parent.gbif_key.first.to_s,
          depositor: parent.depositor.to_s,
          path: @controller.url_for(parent)
        }
      end.to_json
    end

  end
end
