$( document ).ready(function() {
  // shared functions and listeners for copyright statement and licensing fields

  // Disables CC license choices and restricts permits commercial use and morphosource agreement type field values based on rights statement choice
  // Params:
  //   field_prefix: form-specific field prefix ("media", "organization", "batch_submission_media")
  //   reset: Should this choice roll-back previous restrictions? False on form load, true on user actions
  var rightsStatementChange = function(field_prefix, reset = true) {
    var conditions = {
      0: ['http://rightsstatements.org/vocab/InC-RUU/1.0/'],
      1: ['http://rightsstatements.org/vocab/InC/1.0/', 'http://rightsstatements.org/vocab/InC-OW-EU/1.0/', 'http://rightsstatements.org/vocab/InC-EDU/1.0/'],
      2: ['http://rightsstatements.org/vocab/InC-NC/1.0/'],
      3: ['http://rightsstatements.org/vocab/NoC-CR/1.0/', 'http://rightsstatements.org/vocab/NoC-OKLR/1.0/', 'http://rightsstatements.org/vocab/NoC-US/1.0/', 'http://rightsstatements.org/vocab/NKC/1.0/'],
      4: ['http://rightsstatements.org/vocab/NoC-NC/1.0/']
    }

    var conditionMatch = null;
    for (const property in conditions) {
      if ( conditions[property].includes( $(`select#${field_prefix}_rights_statement`).val() ) ) {
        conditionMatch = property;
      }
    }
    switch (conditionMatch) {
      case '0':
        disableLicense(field_prefix, ['https://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by-sa/4.0/', 'https://creativecommons.org/licenses/by-nd/4.0/', 'https://creativecommons.org/licenses/by-nc/4.0/', 'https://creativecommons.org/licenses/by-nc-nd/4.0/', 'https://creativecommons.org/licenses/by-nc-sa/4.0/', 'http://creativecommons.org/publicdomain/zero/1.0/', 'http://creativecommons.org/publicdomain/mark/1.0/', 'http://www.morphosource.org/terms/licenseUnknown/']);
        if (reset) {
          setCommercialUsePermitted(field_prefix, true, false); // reenable both options
        }
        break;
      case '1':
        disableLicense(field_prefix, ['http://creativecommons.org/publicdomain/mark/1.0/']);
        if (reset) {
          limitMorphoSourceUseAgreementToStandard(field_prefix, false); // reenable either standard or permissive
          setCommercialUsePermitted(field_prefix, true, false); // reenable both options
        }
        break;
      case '2':
        disableLicense(field_prefix, ['https://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by-sa/4.0/', 'https://creativecommons.org/licenses/by-nd/4.0/', 'http://creativecommons.org/publicdomain/zero/1.0/', 'http://creativecommons.org/publicdomain/mark/1.0/']);
        limitMorphoSourceUseAgreementToStandard(field_prefix, true); // permissive disallowed (due to non-commercial)
        setCommercialUsePermitted(field_prefix, false, false); // only comm_use_not_permitted allowed
        break;
      case '3':
        disableLicense(field_prefix, ['https://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by-sa/4.0/', 'https://creativecommons.org/licenses/by-nd/4.0/', 'https://creativecommons.org/licenses/by-nc/4.0/', 'https://creativecommons.org/licenses/by-nc-nd/4.0/', 'https://creativecommons.org/licenses/by-nc-sa/4.0/', 'http://creativecommons.org/publicdomain/zero/1.0/']);
        if (reset) {
          limitMorphoSourceUseAgreementToStandard(field_prefix, false); // reenable either standard or permissive
          setCommercialUsePermitted(field_prefix, true, false); // reenable both options
        }
        break;
      case '4':
        disableLicense(field_prefix, ['https://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by-sa/4.0/', 'https://creativecommons.org/licenses/by-nd/4.0/', 'https://creativecommons.org/licenses/by-nc/4.0/', 'https://creativecommons.org/licenses/by-nc-nd/4.0/', 'https://creativecommons.org/licenses/by-nc-sa/4.0/','http://creativecommons.org/publicdomain/zero/1.0/']);
        limitMorphoSourceUseAgreementToStandard(field_prefix, true); // permissive disallowed (due to non-commercial)
        setCommercialUsePermitted(field_prefix, false, false); // only comm_use_not_permitted_allowed
        break;
      default:
        if (reset) {
          disableLicense(field_prefix, []); // reenable all licenses
          limitMorphoSourceUseAgreementToStandard(field_prefix, false); // reenable either standard or permissive
          setCommercialUsePermitted(field_prefix, true, false); // reenable both options
        }
        break;
    }
  };

  // Restricts permits commercial use and morphosource agreement type field values based on license choice
  // Params:
  //   field_prefix: form-specific field prefix ("media", "organization", "batch_submission_media")
  //   reset: Should this choice roll-back previous restrictions? False on form load, true on user actions
  var licenseChange = function(field_prefix, reset = true) {
    var selected_license = $(`select#${field_prefix}_license`).val();
    if ( /\/by-nc/.test(selected_license) ) {
      limitMorphoSourceUseAgreementToStandard(field_prefix, true); // permissive disallowed (due to non-commercial)
      setCommercialUsePermitted(field_prefix, false, false); // only comm_use_not_permitted_allowed
    }
    else if ((selected_license == 'http://www.morphosource.org/terms/licenseUnknown/') || (selected_license == 'http://creativecommons.org/publicdomain/mark/1.0/') || (selected_license == '')) {
      if (reset) {
        limitMorphoSourceUseAgreementToStandard(field_prefix, false); // reenable either standard or permissive
        setCommercialUsePermitted(field_prefix, true, false); // reenable both options
      }
    }
    else {
      setCommercialUsePermitted(field_prefix, true, true); // only comm_use_permitted allowed
      if (reset) {
        limitMorphoSourceUseAgreementToStandard(field_prefix, false); // reenable either standard or permissive
      }
    }
  };

  // Restricts permits commercial use and other field values based on morphosource agreement type
  // Params:
  //   field_prefix: form-specific field prefix ("media", "organization", "batch_submission_media")
  //   reset: Should this choice roll-back previous restrictions? False on form load, true on user actions
  var morphoSourceUseAgreementChange = function(field_prefix, reset = true) {
    var selected_agreement = $(`select#${field_prefix}_morphosource_use_agreement_type`).val();
    if (selected_agreement == 'Standard') {
      var selected_license = $(`select#${field_prefix}_license`).val();
      if ( /\/by-nc/.test(selected_license) ) {
        setCommercialUsePermitted(field_prefix, false, false); // only comm_use_not_permitted_allowed
      }
      else if ((selected_license == 'http://www.morphosource.org/terms/licenseUnknown/') || (selected_license == '')) {
        if (reset) {
          setCommercialUsePermitted(field_prefix, true, false); // reenable both options
        }
      }
      else {
        setCommercialUsePermitted(field_prefix, true, true); // only comm_use_permitted allowed
      }
      unrestrictRequiredArchival(field_prefix);
      unrestrict3DUse(field_prefix);
    }
    else if (selected_agreement == 'Permissive') {
      setCommercialUsePermitted(field_prefix, true, true); // only comm_use_permitted allowed
      limit3DUse(field_prefix, '3DPrintingPermitted');
      limitRequiredArchival(field_prefix, 'EncouragedButNotRequired');
    }
  };

  // Utility functions to carry out field restricting or reenabling

  var limitMorphoSourceUseAgreementToStandard = function(field_prefix, limit_morphosource_use_agreement_to_standard) {
    var permissive_option = $(`#${field_prefix}_morphosource_use_agreement_type option[value="Permissive"]`)
    if (limit_morphosource_use_agreement_to_standard) {
      $(`#${field_prefix}_morphosource_use_agreement_type`).val('Standard');
      permissive_option.attr('disabled','disabled');
    }
    else {
      permissive_option.removeAttr('disabled');
    }
    morphoSourceUseAgreementChange(field_prefix);
  };

  var limitRequiredArchival = function(field_prefix, required_archival_value) {
    $(`select#${field_prefix}_required_archival_of_published_derivatives`).val(required_archival_value);
    $(`select#${field_prefix}_required_archival_of_published_derivatives option[value!="${required_archival_value}"]`).attr('disabled','disabled');
  };

  var unrestrictRequiredArchival = function(field_prefix) {
    $(`select#${field_prefix}_required_archival_of_published_derivatives option`).removeAttr('disabled');
  };

  var limit3DUse = function(field_prefix, required_3d_use_value) {
    $(`select#${field_prefix}_permits_3d_use`).val(required_3d_use_value);
    $(`select#${field_prefix}_permits_3d_use option[value!="${required_3d_use_value}"]`).attr('disabled','disabled');
  };

  var unrestrict3DUse = function(field_prefix) {
    $(`select#${field_prefix}_permits_3d_use option`).removeAttr('disabled');
  };

  // condition combinations and effects
  // commercial_use_permitted = false: comm_use_not_permitted reenabled and set as default, disables comm_use_permitted
  // commercial_use_permitted = true, force = false: reenables both options, does not set a new default
  // commercial_use_permitted = true, force = true: comm_use_permitted reenabled and set as default, disables comm_use_not_permitted
  var setCommercialUsePermitted = function(field_prefix, commercial_use_permitted, force_commercial_use_permitted) {
    var commercial_use_permitted_option = $(`select#${field_prefix}_permits_commercial_use option[value="CommercialUsePermitted"]`);
    var commercial_use_not_permitted_option = $(`select#${field_prefix}_permits_commercial_use option[value="CommercialUseNotPermitted"]`);
    if (commercial_use_permitted) {
      commercial_use_permitted_option.removeAttr('disabled');
      if (force_commercial_use_permitted) {
        $(`select#${field_prefix}_permits_commercial_use`).val('CommercialUsePermitted');
        commercial_use_not_permitted_option.attr('disabled','disabled');
      } else {
        commercial_use_not_permitted_option.removeAttr('disabled');
      }
    }
    else {
      commercial_use_not_permitted_option.removeAttr('disabled');
      $(`select#${field_prefix}_permits_commercial_use`).val('CommercialUseNotPermitted');
      commercial_use_permitted_option.attr('disabled', 'disabled');
    }
  };

  var disableLicense = function(field_prefix, licenses) {
    $(`select#${field_prefix}_license option`).each(function() {
      // Disable options
      if ( licenses.includes( $(this).val() ) ) {
        // Remove select value if disabled selected
        if ( $(`select#${field_prefix}_license`).val() == $(this).val() ) {
          $(`select#${field_prefix}_license`).val('');
        }

        // Disable option
        $(this).attr('disabled', 'disabled');
      } else {
        $(this).removeAttr('disabled');
      }
    });
  };

  // Event triggers using the above functions

  // When a copyright statement is selected, check against license and prune available license options
  $('select[name="media[rights_statement]"]').change(function() {
    event.preventDefault();
    rightsStatementChange('media');
  });

  $('select[name="organization[rights_statement]"]').change(function() {
    event.preventDefault();
    rightsStatementChange('organization');
  });

  $('select[name="batch_submission[media][rights_statement]"]').change(function() {
    event.preventDefault();
    rightsStatementChange('batch_submission_media');
  });

  // When a license statement is selected, prune commercial use options
  $('select[name="media[license]"]').change(function() {
    event.preventDefault();
    licenseChange('media');
  });

  $('select[name="organization[license]"]').change(function() {
    event.preventDefault();
    licenseChange('organization');
  });

  $('select[name="batch_submission[media][license]"]').change(function() {
    event.preventDefault();
    licenseChange('batch_submission_media');
  });

  // When a MorphoSource Use Agreement is selected, prune commercial/3D/rearchival options
  $('select[name="media[morphosource_use_agreement_type]"]').change(function() {
    event.preventDefault();
    morphoSourceUseAgreementChange('media');
  });

  $('select[name="organization[morphosource_use_agreement_type]"]').change(function() {
    event.preventDefault();
    morphoSourceUseAgreementChange('organization');
  });

  $('select[name="batch_submission[media][morphosource_use_agreement_type]"]').change(function() {
    event.preventDefault();
    morphoSourceUseAgreementChange('batch_submission_media');
  });

  // Set up fields on initial page load
  $( document ).ready(function() {
    if($('select[name="media[rights_statement]"]').length) {
      rightsStatementChange('media', false);
      licenseChange('media', false);
      morphoSourceUseAgreementChange('media', false);
    }
    else if($('select[name="organization[rights_statement]"]').length) {
      rightsStatementChange('organization', false);
      licenseChange('organization', false);
      morphoSourceUseAgreementChange('organization', false);
    } 
    else if($('select[name="batch_submission[media][rights_statement]"]').length) {
      rightsStatementChange('batch_submission_media', false);
      licenseChange('batch_submission_media', false);
      morphoSourceUseAgreementChange('batch_submission_media', false);
    }
  });
});
