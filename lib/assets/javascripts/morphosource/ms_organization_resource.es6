/*
 * Represents a Child work or related Collection
 */
export default class OrganizationResource {
    constructor(id, title, organization_type, institution_code, institution_name, collection_code, recordset_id, description, related_url, address, city, state_province, country, contact_person) {
        this.id = id
        this.title = title
        this.organization_type = organization_type
        this.institution_code = institution_code
        this.institution_name = institution_name
        this.collection_code = collection_code
        this.recordset_id = recordset_id
        this.description = description
        this.related_url = related_url
        this.address = address
        this.city = city
        this.state_province = state_province
        this.country = country
        this.contact_person = contact_person
        this.index = 0
    }
}
