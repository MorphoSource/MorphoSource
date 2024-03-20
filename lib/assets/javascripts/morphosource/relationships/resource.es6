/*
 * Represents a Child work or related Collection
 */
export default class Resource {
    constructor(id, title, removable) {
        this.id = id
        this.title = title
        this.removable = removable
        this.index = 0
    }
}
