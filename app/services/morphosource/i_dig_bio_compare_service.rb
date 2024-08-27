module Morphosource
  class IDigBioCompareService

    def self.call(specimen_id, force_update=false)
      new(specimen_id, force_update).call
    end

    def initialize(specimen_id, force_update)
      @specimen_id = specimen_id
      @force_update = force_update
      @specimen = SolrDocument.find(specimen_id)
    end

    def call
      occurrence_id = @specimen["occurrence_id_tesim"]
      if idigbio_match_found(occurrence_id) == 1
        @idigbio_occurrence = @occurrence_id_results[:data].first
        if idigbio_recordset_different_from_org?(@specimen)
          Rails.logger.debug "Specimen #{specimen["id"]} not synced because the organization (#{specimen["organization_id_tesim"].first}) has recordset ID(s) (#{@org_recordset_ids.join(', ')}) different from the iDigBio-supplied recordset ID #{@idb_recordset_id}."
          return nil
        else          
byebug
          return Morphosource::IDigBioGetMetadataService.call(@specimen_id, @force_update)

        end
      elsif idigbio_match_found(occurrence_id) > 1
        Rails.logger.debug "Specimen #{specimen["id"]} not synced because multiple records found for OID: #{specimen["occurrence_id_tesim"].first}"
        return nil
      end
    end

    def idigbio_match_found(occurrence_id)
      return -1 unless occurrence_id_valid?(occurrence_id)
      @occurrence_id_results = Morphosource::IDigBio.search({'occurrenceid' => occurrence_id})
      return -1 unless (@occurrence_id_results[:status] == :success) && (@occurrence_id_results[:data].length > 0)
      return @occurrence_id_results[:data].length 
    end

    def occurrence_id_valid?(occurrence_id)
      # valid if 8 characters minimum AND has both a letter and a number
      occurrence_id.present? && occurrence_id.first.length >= 8 &&
        occurrence_id.first.count("0-9") > 0 && occurrence_id.first.count("a-zA-Z") > 0
    end

    def idigbio_recordset_different_from_org?(specimen)
      org_id = specimen["organization_id_tesim"]
      return false unless org_id.present?
      org = SolrDocument.find(org_id)
      return false unless org.present?
      @org_recordset_ids = org["recordset_id_tesim"]
      if @org_recordset_ids.present?
        if (@idb_recordset_id = @idigbio_occurrence.dig("indexTerms", "recordset")).present?
          return !@org_recordset_ids.include?(@idb_recordset_id)
        end
      end
      return false
    end

  end
end
