module Morphosource
  class IDigBioUpdateService
    include Morphosource::MessageHelper

    def self.call(bso_id, save_work=false, system_update=false, log_file=nil, canonical_taxonomy_id, taxonomy_id_array, taxonomy_params_array, biospec_model_params)
      new(bso_id, save_work, system_update, log_file, canonical_taxonomy_id, taxonomy_id_array, taxonomy_params_array, biospec_model_params).call
    end

    def initialize(bso_id, save_work, system_update, log_file, canonical_taxonomy_id, taxonomy_id_array, taxonomy_params_array, biospec_model_params)
      @save_work = save_work
      @system_update = system_update
      @log_file = log_file
      @canonical_taxonomy_id = canonical_taxonomy_id
      @taxonomy_id_array = taxonomy_id_array
      @taxonomy_params_array = taxonomy_params_array
      @biospec_model_params = biospec_model_params
      @log = log_file.present?? Logger.new(log_file) : Logger.new(STDOUT) 
      @bso = BiologicalSpecimen.find(bso_id)
    end

    def call
      apply_idigbio_update
    end
  
    def apply_idigbio_update   
      add_new_taxonomies
      link_taxonomies
      update_metadata_from_idigbio
    end
  
    def add_new_taxonomies
      # add new taxonomy if any
      @taxonomy_params_array.each do |taxon_params|
        new_taxon_id = prepare_and_create_taxonomy(taxon_params)
        @taxonomy_id_array << new_taxon_id
        if taxon_params[:canonical]
          @canonical_taxonomy_id = new_taxon_id
        end
      end
    end
  
    def link_taxonomies
      # now link taxonomy (new or existing) to the bso
      if @taxonomy_id_array.present?
        old_taxonomy_id = @bso.taxonomy_id.to_a
        @bso.taxonomy_id = (@bso.taxonomy_id + @taxonomy_id_array).uniq
      end
      if @canonical_taxonomy_id.present?
        old_canonical_taxonomy = @bso.canonical_taxonomy.to_a
        @bso.canonical_taxonomy_will_change! unless old_canonical_taxonomy.include? @canonical_taxonomy_id
        @bso.canonical_taxonomy = (@bso.canonical_taxonomy << @canonical_taxonomy_id).uniq
      end
  
      if @bso.taxonomy_id_changed?
        @log.debug "IDigBioUpdateService: BSO #{@bso.id} : taxonomy_id #{old_taxonomy_id} will be updated to '#{@bso.taxonomy_id.to_a}'"
      end
      if @bso.canonical_taxonomy_changed?
        @log.debug "IDigBioUpdateService: BSO #{@bso.id} : canonical_taxonomy #{old_canonical_taxonomy} will be updated to '#{@bso.canonical_taxonomy.to_a}'"
      end
    end
  
    def update_metadata_from_idigbio
      # sync bso metadata
      @biospec_model_params.each do |key, value|
        @bso.send("#{key}=", Array(value) )
        if @bso.send("#{key}_changed?")
          @log.debug "IDigBioUpdateService: BSO #{@bso.id} : #{key} field will be updated to '#{value}'"
        end
      end
      if @bso.idigbio_uuid_changed?
        @bso.idigbio_link_origin = @system_update ? ["system_generated"] : ["user"]
      end
      @bso.title = [generated_title]
      @bso.save if @save_work
    end

    private

    def generated_title
      inst = @bso.institution_code&.first.presence || ''
      coll = @bso.collection_code&.first.presence || ''
      cnum = @bso.catalog_number&.first.presence || ''
      case
      when inst.present? || coll.present? || cnum.present?
        collection_catalog_generated_title(inst, coll, cnum)
      when @bso.identifier.present?
        identifier_generated_title(@bso.identifier)
      else
        fallback_generated_title(@bso.vouchered, ::User.find_by_user_key(@bso.depositor))
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
