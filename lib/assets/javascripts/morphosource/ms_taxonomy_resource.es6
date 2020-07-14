/*
 * Represents a Child work or related Collection
 */
export default class TaxonomyResource {
        constructor(
            id, 
            title, 
            taxonomy_domain, 
            taxonomy_kingdom,
            taxonomy_phylum,
            taxonomy_superclass,
            taxonomy_class,
            taxonomy_subclass,
            taxonomy_superorder,
            taxonomy_order,
            taxonomy_suborder,
            taxonomy_superfamily,
            taxonomy_family,
            taxonomy_subfamily,
            taxonomy_tribe,
            taxonomy_genus,
            taxonomy_subgenus,
            taxonomy_species,
            taxonomy_subspecies,
            trusted,
            gbif_key,
            depositor,
            depositor_link
        ) {
            this.id = id
            this.title = title
            this.taxonomy_domain = taxonomy_domain
            this.taxonomy_kingdom = taxonomy_kingdom
            this.taxonomy_phylum = taxonomy_phylum
            this.taxonomy_superclass = taxonomy_superclass
            this.taxonomy_class = taxonomy_class
            this.taxonomy_subclass = taxonomy_subclass
            this.taxonomy_superorder = taxonomy_superorder
            this.taxonomy_order = taxonomy_order
            this.taxonomy_suborder = taxonomy_suborder
            this.taxonomy_superfamily = taxonomy_superfamily
            this.taxonomy_family = taxonomy_family
            this.taxonomy_subfamily = taxonomy_subfamily
            this.taxonomy_tribe = taxonomy_tribe
            this.taxonomy_genus = taxonomy_genus
            this.taxonomy_subgenus = taxonomy_subgenus
            this.taxonomy_species = taxonomy_species
            this.taxonomy_subspecies = taxonomy_subspecies
            this.trusted = trusted
            this.gbif_key = gbif_key
            this.depositor = depositor
            this.depositor_link = depositor_link
            this.index = 0
    }
}
