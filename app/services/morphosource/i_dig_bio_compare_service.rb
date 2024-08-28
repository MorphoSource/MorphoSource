module Morphosource
  class IDigBioCompareService

    def self.call(specimen_id)
      new(specimen_id).call
    end

    def initialize(specimen_id)
      @specimen_id = specimen_id
      @specimen = SolrDocument.find(specimen_id)
    end

    def call
      # Check all conditions to see if a sync is needed
      # Return metadata if a sync is needed.  Otherwise return nothing.
      occurrence_id = @specimen["occurrence_id_tesim"]
      return nil unless occurrence_id_valid?(occurrence_id)

      @occurrence_id_results = Morphosource::IDigBio.search({'occurrenceid' => occurrence_id})
      return nil unless (@occurrence_id_results[:status] == :success) && (@occurrence_id_results[:data].length > 0)

      if @occurrence_id_results[:data].length > 1
        Rails.logger.debug "Specimen #{specimen["id"]} not synced because multiple records found for OID: #{specimen["occurrence_id_tesim"].first}"
        return nil
      end

      # Only 1 result found
      if idigbio_recordset_different_from_org?(@specimen)
        Rails.logger.debug "Specimen #{specimen["id"]} not synced because the organization (#{specimen["organization_id_tesim"].first}) has recordset ID(s) (#{@org_recordset_ids.join(', ')}) different from the iDigBio-supplied recordset ID #{@idb_recordset_id}."
        return nil
      end
byebug

      return Morphosource::IDigBioGetMetadataService.call(@specimen_id)
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
        if (@idb_recordset_id = @occurrence_id_results[:data].first.dig("indexTerms", "recordset")).present?
          return !@org_recordset_ids.include?(@idb_recordset_id)
        end
      end
      return false
    end

  end
end
