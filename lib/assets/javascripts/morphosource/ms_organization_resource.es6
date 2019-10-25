/*
 * Represents a Child work or related Collection
 */
export default class OrganizationResource {
    constructor(id, title, organization_code, description, address, city, state_province, country) {
        this.id = id
        this.title = title
        this.organization_code = organization_code
        this.description = description
        this.address = address
        this.city = city
        this.state_province = state_province
        this.country = country
        this.index = 0
    }
}
