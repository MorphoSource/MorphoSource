/*
 * Represents a Child work or related Collection
 */
export default class CulturalHeritageObjectResource {
    constructor(
            id, 
            title, 
            bibliographic_citation,
            catalog_number,
            collection_code,
            institution_code,
            latitude,
            longitude,
            numeric_time,
            original_location,
            periodic_time,
            vouchered,
            cho_type,
            material,
            short_title
        ) {
        this.id = id
        this.title = title
        this.bibliographic_citation = bibliographic_citation
        this.catalog_number = catalog_number
        this.collection_code = collection_code
        this.institution_code = institution_code
        this.latitude = latitude
        this.longitude = longitude
        this.numeric_time = numeric_time
        this.original_location = original_location
        this.periodic_time = periodic_time
        this.vouchered = vouchered,
        this.cho_type = cho_type,
        this.material = material,
        this.short_title = short_title,
        this.index = 0
    }
}
