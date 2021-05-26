export class Person {
  /**
   * Initialize the Person 
   * @param {String} name the name of the agent
   */
  constructor(name, email="") {
    this.type = 'person'
    this.name = name
    // MS2 customization: this is for passing the email address of the individual user selected
    this.email = email
  }
}

