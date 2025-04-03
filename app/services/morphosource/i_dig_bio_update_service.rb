module Morphosource
  class IDigBioUpdateService

    attr_reader :specimen, :save_work, :system_update, :canonical_taxonomy_id, :taxonomy_id_array, :taxonomy_params_array, :biospec_model_params

    def self.call(specimen_id, save_work=false, system_update=false, params_for_update)
      new(specimen_id, save_work, system_update, params_for_update).call
    end

    def initialize(specimen_id, save_work, system_update, params_for_update)
      @save_work = save_work
      @system_update = system_update
      @canonical_taxonomy_id = params_for_update[:canonical_taxonomy_id]
      @taxonomy_id_array = params_for_update[:taxonomy_id_array]
      @taxonomy_params_array = params_for_update[:taxonomy_params_array]
      @biospec_model_params = params_for_update[:biospec_model_params]
      @specimen = BiologicalSpecimen.find(specimen_id)
    end

    def call
      apply_idigbio_update
    end
  
    def apply_idigbio_update   
      if save_work   
        add_new_taxonomies
        link_taxonomies
      end
      update_metadata_from_idigbio
    end
  
    def add_new_taxonomies
      # add new taxonomy if any
      taxonomy_params_array.each do |taxon_params|
        new_taxon_id = prepare_and_create_taxonomy(taxon_params)
        @taxonomy_id_array << new_taxon_id
        if taxon_params[:canonical]
          @canonical_taxonomy_id = new_taxon_id
        end
      end
    end

    def prepare_and_create_taxonomy(params)
      attributes_for_actor = Hyrax::TaxonomyForm.model_attributes(params)
      attributes_for_actor.merge!({ visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC })
      curation_concern = Taxonomy.new
      env = Hyrax::Actors::Environment.new(curation_concern, ::Ability.new(User.find_by_ms_id(@specimen.depositor)), attributes_for_actor)
      Hyrax::CurationConcern.actor.create(env)
      return curation_concern.id
    end
  
    def link_taxonomies
      # now link taxonomy (new or existing) to the specimen
      if taxonomy_id_array.present?
        old_taxonomy_id = specimen.taxonomy_id.to_a
        @specimen.taxonomy_id = (specimen.taxonomy_id + taxonomy_id_array).uniq
      end
      if canonical_taxonomy_id.present?
        old_canonical_taxonomy = specimen.canonical_taxonomy.to_a
        @specimen.canonical_taxonomy_will_change! unless old_canonical_taxonomy.include? canonical_taxonomy_id
        @specimen.canonical_taxonomy = (specimen.canonical_taxonomy << canonical_taxonomy_id).uniq
      end
  
      if specimen.taxonomy_id_changed?
        Rails.logger.debug "IDigBioUpdateService: specimen #{specimen.id} : taxonomy_id #{old_taxonomy_id} will be updated to '#{specimen.taxonomy_id.to_a}'"
      end
      if specimen.canonical_taxonomy_changed?
        Rails.logger.debug "IDigBioUpdateService: specimen #{specimen.id} : canonical_taxonomy #{old_canonical_taxonomy} will be updated to '#{specimen.canonical_taxonomy.to_a}'"
      end
    end
  
    def update_metadata_from_idigbio
      # sync specimen metadata
      biospec_model_params.each do |key, value|
        @specimen.send("#{key}=", Array(value) )
        if @specimen.send("#{key}_changed?")
          Rails.logger.debug "IDigBioUpdateService: specimen #{specimen.id} : #{key} field will be updated to '#{value}'"
        end
      end
      if specimen.idigbio_uuid_changed?
        @specimen.idigbio_link_origin = system_update ? ["system_generated"] : ["user"]
      end
      @specimen.title = [generated_title]
      @specimen.save if save_work
    end

    private

    def generated_title
      inst = specimen.institution_code&.first.presence || ''
      coll = specimen.collection_code&.first.presence || ''
      cnum = specimen.catalog_number&.first.presence || ''
      case
      when inst.present? || coll.present? || cnum.present?
        collection_catalog_generated_title(inst, coll, cnum)
      when specimen.identifier.present?
        identifier_generated_title(specimen.identifier)
      else
        fallback_generated_title(specimen.vouchered, ::User.find_by_user_key(specimen.depositor))
      end
    end

    def collection_catalog_generated_title(institution_code='', collection_code='', catalog_number='')
      [institution_code, collection_code, catalog_number].keep_if { |x| x.presence } .join(':')
    end

    def identifier_generated_title(identifier)
      identifier.sort.join(', ')
    end

    def fallback_generated_title(vouchered, user)
      if vouchered.present? && vouchered.first == 'Yes'
        voucher_term = 'Vouchered'
      else
        voucher_term = 'Unvouchered'
      end
      user_term = user.display_name.present? ? user.display_name : user.email
      I18n.t('morphosource.fallback_object_title', voucher: voucher_term, user: user_term)
    end

  end
end
