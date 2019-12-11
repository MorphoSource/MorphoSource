/*
 * Represents a Child work or related Collection
 */
export default class DeviceResource {
    constructor(id, title, creator, modality, description, organization_institution) {
        this.id = id
        this.title = title
        this.creator = creator
        this.modality = modality
        this.description = description
        this.organization_institution = organization_institution
        this.index = 0
    }
}
