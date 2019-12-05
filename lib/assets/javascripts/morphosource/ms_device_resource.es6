/*
 * Represents a Child work or related Collection
 */
export default class DeviceResource {
    constructor(id, title, creator, modality, description) {
        this.id = id
        this.title = title
        this.creator = creator
        this.modality = modality
        this.description = description
        this.index = 0
    }
}
