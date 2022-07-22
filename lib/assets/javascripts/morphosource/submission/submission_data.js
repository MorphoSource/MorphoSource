class SubmissionData {
  constructor(depositor=null, sessionState=null) {
    if (depositor) {
      this.depositor = depositor;
    }
    if (sessionState) {
      this.constructSubmissionParams(sessionState);
      this.constructCreateParams(sessionState);
    }
  }

  constructSubmissionParams(sessionState) {
    var submissionParamsArray = ['saved_step', 'fund_code', 'submission_media_type',
      'submission_modality', 'raw_or_derived_media', 'parent_media_list',
      'parent_media_not_in_ms', 'biological_specimen_or_cultural_heritage_object',
      'biological_specimen_id', 'idigbio_id', 'will_create_biological_specimen',
      'cultural_heritage_object_id', 'will_create_cultural_heritage_object',
      'organization_id', 'no_organization', 'will_create_organization',
      'taxonomy_id_array', 'taxonomy_gbif_key_array', 'will_create_taxonomy',
      'device_id', 'will_create_device', 'device_organization_id',
      'device_no_organization', 'will_create_device_organization'];

    for (let param of submissionParamsArray) {
      if (sessionState.form_data && sessionState.form_data.hasOwnProperty(param)) {
        this[this.underscoreToCamelCase(param)] = sessionState.form_data[param];
      }
    }
  }

  constructCreateParams(sessionState) {
    var createParamsHash = {
      'organization': 'organizationCreateParams',
      'taxonomy': 'taxonomyCreateParams',
      'biological_specimen': 'biologicalSpecimenCreateParams',
      'cultural_heritage_object': 'culturalHeritageObjectCreateParams',
      'device': 'deviceCreateParams',
      'device_organization': 'deviceOrganizationCreateParams',
      'imaging_event': 'imagingEventCreateParams',
      'processing_event': 'processingEventCreateParams'
    };

    for (let workName in createParamsHash) {
      if (sessionState.work_data && sessionState.work_data.hasOwnProperty(workName)) {
        this[createParamsHash[workName]] =
          this.objectToCreateParams(
            sessionState.work_data[workName],
            workName
          );
      }
    }
  }

  objectToCreateParams(object, objectName) {
    var paramArray = [];
    for (let property in object) {
      if (object[property]){
        if (Array.isArray(object[property])){
          for (let element of object[property]) {
            paramArray.push({ 'name': objectName + '[' + property + '][]', 'value': element });
          }
        }else if (object[property] instanceof Object){
          continue;
        }else{
          paramArray.push({ 'name': objectName + '[' + property + ']', 'value': object[property] });
        }
      }
    }
    return paramArray;
  }

  setPhysicalObjectDefaults() {
    this.biologicalSpecimenId = null;
    this.idigbioId = null;
    this.willCreateBiologicalSpecimen = null;
    this.culturalHeritageObjectId = null;
    this.willCreateCulturalHeritageObject = null;
  }

  setOrganizationDefaults() {
    this.organizationId = null;
    this.organizationCollectionCode = null;
    this.organizationInstitutionCode = null;
    this.noOrganization =  null;
    this.willCreateOrganization = null;
    this.organizationCreateParams = null;
  }

  setDeviceDefaults() {
    this.deviceId = null;
    this.willCreateDevice = null;
    this.deviceCreateParams = null;
  }

  setDeviceOrganizationDefaults() {
    this.deviceOrganizationId = null;
    this.deviceNoOrganization = null;
    this.willCreateDeviceOrganization = null;
    this.deviceOrganizationCreateParams = null;
  }

  underscoreToCamelCase(x) {
  return x.replace(/([-_][a-z])/ig, ($1) => {
      return $1.toUpperCase()
        .replace('-', '')
        .replace('_', '');
    });
  }

  // Currently unused but functional
  save() {
    console.log('Saving data...');

    let createParams = ['organizationCreateParams', 'taxonomyCreateParams',
      'biologicalSpecimenCreateParams', 'culturalHeritageObjectCreateParams', 'deviceCreateParams',
      'deviceOrganizationCreateParams', 'imagingEventCreateParams',
      'processingEventCreateParams'];

    saveDataObj = [];

    for (let k in this) {
      if (this[k] instanceof Function ) {
        continue;
      } else if (createParams.includes(k)) {
        if (Array.isArray(this[k])) {
          for (let createParamField of this[k]) {
            if (createParamField['name'] != 'utf8' && createParamField['name'] != 'authenticity_token') {
              if (createParamField['name'].slice(-2) == '[]') {
                // Multi-value field
                saveDataObj.push(
                  { 'name': 'submission[work_data[' + createParamField['name'].slice(0, -2) + ']][]',
                    'value': createParamField['value'] }
                );
              } else {
                saveDataObj.push(
                  { 'name': 'submission[work_data[' + createParamField['name'] + ']]',
                    'value': createParamField['value'] }
                );
              }
            }
          }
        }
      } else {
        saveDataObj.push(
          { 'name': 'submission[form_data[' + camelcaseToUnderscore(k) + ']]',
            'value': this[k] }
        );
      }
    }

    console.log(saveDataObj);

    $.post('save_data', saveDataObj, function(post_data){
      console.log('Data successfully saved!');
    });

  };
}