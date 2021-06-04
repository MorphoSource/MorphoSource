export class Grant {
  /**
   * Initialize the Grant 
   * @param {Agent} agent the agent the grant applies to
   * @param {String} access the access level to grant
   * @param {String} accessLabel the access level to display 
   */
  constructor(agent, access, accessLabel) {
    this.agent = agent
    this.access = access
    this.accessLabel = accessLabel
    this.index = 0
  }

  get name() {
    return this.agent.name
  }

  get type() {
    return this.agent.type
  }

  // MS2 customization: this is for passing the email address of the individual user selected
  get email() {
    return this.agent.email
  }

}


