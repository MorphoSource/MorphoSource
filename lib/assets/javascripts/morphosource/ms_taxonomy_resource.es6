/*
 * Represents a Child work or related Collection
 */
export default class TaxonomyResource {
    constructor(id, title, taxonomy_domain, taxonomy_kingdom) {
        this.id = id
        this.title = title
        this.taxonomy_domain = taxonomy_domain
        this.taxonomy_kingdom = taxonomy_kingdom
        this.index = 0
    }
}
