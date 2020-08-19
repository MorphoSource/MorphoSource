/*
 * Represents a Child work or related Collection
 */
export default class BiologicalSpecimenResource {
    constructor(
            id, 
            title, 
            bibliographic_citation,
            catalog_number,
            collection_code,
            canonical_taxonomy,
            institution_code,
            latitude,
            longitude,
            numeric_time,
            original_location,
            periodic_time,
            vouchered,
            idigbio_recordset_id,
            idigbio_uuid,
            is_type_specimen,
            occurrence_id,
            source_of_record,
            sex
        ) {
        this.id = id
        this.title = title
        this.bibliographic_citation = bibliographic_citation
        this.catalog_number = catalog_number
        this.collection_code = collection_code
        this.canonical_taxonomy = canonical_taxonomy
        this.institution_code = institution_code
        this.latitude = latitude
        this.longitude = longitude
        this.numeric_time = numeric_time
        this.original_location = original_location
        this.periodic_time = periodic_time
        this.vouchered = vouchered
        this.idigbio_recordset_id = idigbio_recordset_id
        this.idigbio_uuid = idigbio_uuid
        this.is_type_specimen = is_type_specimen
        this.occurrence_id = occurrence_id
        this.sex = sex
        this.source_of_record = source_of_record
        this.index = 0
    }
}
