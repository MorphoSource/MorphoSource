$( document ).ready(function() {
  // shared functions and listeners for copyright statement and licensing fields
  var rightsStatementChange = function(field_prefix) {
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
        setCommercialUsePermitted(field_prefix, true, false);
        break;
      case '1':
        disableLicense(field_prefix, ['http://creativecommons.org/publicdomain/mark/1.0/']);
        limitMorphoSourceUseAgreementToStandard(field_prefix, false);
        setCommercialUsePermitted(field_prefix, true, false);
        break;
      case '2':
        disableLicense(field_prefix, ['https://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by-sa/4.0/', 'https://creativecommons.org/licenses/by-nd/4.0/', 'http://creativecommons.org/publicdomain/zero/1.0/', 'http://creativecommons.org/publicdomain/mark/1.0/']);
        limitMorphoSourceUseAgreementToStandard(field_prefix, true);
        setCommercialUsePermitted(field_prefix, false, false);
        break;
      case '3':
        disableLicense(field_prefix, ['https://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by-sa/4.0/', 'https://creativecommons.org/licenses/by-nd/4.0/', 'https://creativecommons.org/licenses/by-nc/4.0/', 'https://creativecommons.org/licenses/by-nc-nd/4.0/', 'https://creativecommons.org/licenses/by-nc-sa/4.0/', 'http://creativecommons.org/publicdomain/zero/1.0/']);
        limitMorphoSourceUseAgreementToStandard(field_prefix, false);
        setCommercialUsePermitted(field_prefix, true, false);
        break;
      case '4':
        disableLicense(field_prefix, ['https://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by-sa/4.0/', 'https://creativecommons.org/licenses/by-nd/4.0/', 'https://creativecommons.org/licenses/by-nc/4.0/', 'https://creativecommons.org/licenses/by-nc-nd/4.0/', 'https://creativecommons.org/licenses/by-nc-sa/4.0/','http://creativecommons.org/publicdomain/zero/1.0/']);
        limitMorphoSourceUseAgreementToStandard(field_prefix, true);
        setCommercialUsePermitted(field_prefix, false, false);
        break;
      default:
        disableLicense(field_prefix, []);
        limitMorphoSourceUseAgreementToStandard(field_prefix, false);
        setCommercialUsePermitted(field_prefix, true, false);
        break;
    }
  };

  var licenseChange = function(field_prefix) {
    var selected_license = $(`select#${field_prefix}_license`).val();
    if ( /\/by-nc/.test(selected_license) ) {
      limitMorphoSourceUseAgreementToStandard(field_prefix, true);
      setCommercialUsePermitted(field_prefix, false, false);
    }
    else if ((selected_license == 'http://www.morphosource.org/terms/licenseUnknown/') || (selected_license == 'http://creativecommons.org/publicdomain/mark/1.0/') || (selected_license == '')) {
      limitMorphoSourceUseAgreementToStandard(field_prefix, false);
      setCommercialUsePermitted(field_prefix, true, false);
    }
    else {
      limitMorphoSourceUseAgreementToStandard(field_prefix, false);
      setCommercialUsePermitted(field_prefix, true, true);
    }
  };

  var morphoSourceUseAgreementChange = function(field_prefix) {
    var selected_agreement = $(`select#${field_prefix}_morphosource_use_agreement_type`).val();
    if (selected_agreement == 'Standard') {
      var selected_license = $(`select#${field_prefix}_license`).val();
      if ( /\/by-nc/.test(selected_license) ) {
        setCommercialUsePermitted(field_prefix, false, false);
      }
      else if ((selected_license == 'http://www.morphosource.org/terms/licenseUnknown/') || (selected_license == '')) {
        setCommercialUsePermitted(field_prefix, true, false);
      }
      else {
        setCommercialUsePermitted(field_prefix, true, true);
      }
      unrestrictRequiredArchival(field_prefix);
      unrestrict3DUse(field_prefix);
    }
    else if (selected_agreement == 'Permissive') {
      setCommercialUsePermitted(field_prefix, true, true);
      limit3DUse(field_prefix, '3DPrintingPermitted');
      limitRequiredArchival(field_prefix, 'EncouragedButNotRequired');
    }
  };

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

  var setCommercialUsePermitted = function(field_prefix, commercial_use_permitted, force_commercial_use_permitted) {
    var commercial_use_permitted_option = $(`select#${field_prefix}_permits_commercial_use option[value="CommercialUsePermitted"]`);
    var commercial_use_not_permitted_option = $(`select#${field_prefix}_permits_commercial_use option[value="CommercialUseNotPermitted"]`);
    if (commercial_use_permitted) {
      commercial_use_permitted_option.removeAttr('disabled');
      if (force_commercial_use_permitted) {
        $(`select#${field_prefix}_permits_commercial_use`).val('CommercialUsePermitted');
        commercial_use_not_permitted_option.attr('disabled','disabled');
      }
      else {
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

  $( document ).ready(function() {
    if($('select[name="media[rights_statement]"]').length) {
      rightsStatementChange('media');
      licenseChange('media');
      morphoSourceUseAgreementChange('media');
    }
    else if($('select[name="organization[rights_statement]"]').length) {
      rightsStatementChange('organization');
      licenseChange('organization');
      morphoSourceUseAgreementChange('organization');
    } 
    else if($('select[name="batch_submission[media][rights_statement]"]').length) {
      rightsStatementChange('batch_submission_media');
      licenseChange('batch_submission_media');
      morphoSourceUseAgreementChange('batch_submission_media');
    }
  });
});
