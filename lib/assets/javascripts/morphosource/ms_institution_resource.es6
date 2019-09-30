/*
 * Represents a Child work or related Collection
 */
export default class InstitutionResource {
    constructor(id, title, institution_code, description, address, city, state_province, country) {
        this.id = id
        this.title = title
        this.institution_code = institution_code
        this.description = description
        this.address = address
        this.city = city
        this.state_province = state_province
        this.country = country
        this.index = 0
    }
}
