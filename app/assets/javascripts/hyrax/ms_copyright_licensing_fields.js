$( document ).ready(function() {
  // shared functions and listeners for copyright statement and licensing fields
  var rightsStatementChange = function(media_or_organization) {
    var conditions = {
      0: ['http://rightsstatements.org/vocab/InC-RUU/1.0/'],
      1: ['http://rightsstatements.org/vocab/InC/1.0/', 'http://rightsstatements.org/vocab/InC-OW-EU/1.0/', 'http://rightsstatements.org/vocab/InC-EDU/1.0/'],
      2: ['http://rightsstatements.org/vocab/InC-NC/1.0/'],
      3: ['http://rightsstatements.org/vocab/NoC-CR/1.0/', 'http://rightsstatements.org/vocab/NoC-OKLR/1.0/', 'http://rightsstatements.org/vocab/NoC-US/1.0/', 'http://rightsstatements.org/vocab/NKC/1.0/'],
      4: ['http://rightsstatements.org/vocab/NoC-NC/1.0/']
    }

    var conditionMatch = null;
    for (const property in conditions) {
      if ( conditions[property].includes( $(`select#${media_or_organization}_rights_statement`).val() ) ) {
        conditionMatch = property;
      }
    }
    switch (conditionMatch) {
      case '0':
        disableLicense(media_or_organization, ['https://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by-sa/4.0/', 'https://creativecommons.org/licenses/by-nd/4.0/', 'https://creativecommons.org/licenses/by-nc/4.0/', 'https://creativecommons.org/licenses/by-nc-nd/4.0/', 'https://creativecommons.org/licenses/by-nc-sa/4.0/', 'http://creativecommons.org/publicdomain/zero/1.0/', 'http://creativecommons.org/publicdomain/mark/1.0/', 'http://www.morphosource.org/terms/licenseUnknown/']);
        setCommercialUsePermitted(media_or_organization, true, false);
        break;
      case '1':
        disableLicense(media_or_organization, ['http://creativecommons.org/publicdomain/mark/1.0/']);
        limitMorphoSourceUseAgreementToStandard(media_or_organization, false);
        setCommercialUsePermitted(media_or_organization, true, false);
        break;
      case '2':
        disableLicense(media_or_organization, ['https://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by-sa/4.0/', 'https://creativecommons.org/licenses/by-nd/4.0/', 'http://creativecommons.org/publicdomain/zero/1.0/', 'http://creativecommons.org/publicdomain/mark/1.0/']);
        limitMorphoSourceUseAgreementToStandard(media_or_organization, true);
        setCommercialUsePermitted(media_or_organization, false, false);
        break;
      case '3':
        disableLicense(media_or_organization, ['https://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by-sa/4.0/', 'https://creativecommons.org/licenses/by-nd/4.0/', 'https://creativecommons.org/licenses/by-nc/4.0/', 'https://creativecommons.org/licenses/by-nc-nd/4.0/', 'https://creativecommons.org/licenses/by-nc-sa/4.0/', 'http://creativecommons.org/publicdomain/zero/1.0/']);
        limitMorphoSourceUseAgreementToStandard(media_or_organization, false);
        setCommercialUsePermitted(media_or_organization, true, false);
        break;
      case '4':
        disableLicense(media_or_organization, ['https://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by-sa/4.0/', 'https://creativecommons.org/licenses/by-nd/4.0/', 'https://creativecommons.org/licenses/by-nc/4.0/', 'https://creativecommons.org/licenses/by-nc-nd/4.0/', 'https://creativecommons.org/licenses/by-nc-sa/4.0/','http://creativecommons.org/publicdomain/zero/1.0/']);
        limitMorphoSourceUseAgreementToStandard(media_or_organization, true);
        setCommercialUsePermitted(media_or_organization, false, false);
        break;
      default:
        disableLicense(media_or_organization, []);
        limitMorphoSourceUseAgreementToStandard(media_or_organization, false);
        setCommercialUsePermitted(media_or_organization, true, false);
        break;
    }
  };

  var licenseChange = function(media_or_organization) {
    var selected_license = $(`select#${media_or_organization}_license`).val();
    if ( /\/by-nc/.test(selected_license) ) {
      limitMorphoSourceUseAgreementToStandard(media_or_organization, true);
      setCommercialUsePermitted(media_or_organization, false, false);
    }
    else if ((selected_license == 'http://www.morphosource.org/terms/licenseUnknown/') || (selected_license == 'http://creativecommons.org/publicdomain/mark/1.0/') || (selected_license == '')) {
      limitMorphoSourceUseAgreementToStandard(media_or_organization, false);
      setCommercialUsePermitted(media_or_organization, true, false);
    }
    else {
      limitMorphoSourceUseAgreementToStandard(media_or_organization, false);
      setCommercialUsePermitted(media_or_organization, true, true);
    }
  };

  var morphoSourceUseAgreementChange = function(media_or_organization) {
    var selected_agreement = $(`select#${media_or_organization}_morphosource_use_agreement_type`).val();
    if (selected_agreement == 'Standard') {
      var selected_license = $(`select#${media_or_organization}_license`).val();
      if ( /\/by-nc/.test(selected_license) ) {
        setCommercialUsePermitted(media_or_organization, false, false);
      }
      else if ((selected_license == 'http://www.morphosource.org/terms/licenseUnknown/') || (selected_license == '')) {
        setCommercialUsePermitted(media_or_organization, true, false);
      }
      else {
        setCommercialUsePermitted(media_or_organization, true, true);
      }
      unrestrictRequiredArchival(media_or_organization);
      unrestrict3DUse(media_or_organization);
    }
    else if (selected_agreement == 'Permissive') {
      setCommercialUsePermitted(media_or_organization, true, true);
      limit3DUse(media_or_organization, '3DPrintingPermitted');
      limitRequiredArchival(media_or_organization, 'EncouragedButNotRequired');
    }
  };

  var limitMorphoSourceUseAgreementToStandard = function(media_or_organization, limit_morphosource_use_agreement_to_standard) {
    var permissive_option = $(`#${media_or_organization}_morphosource_use_agreement_type option[value="Permissive"]`)
    if (limit_morphosource_use_agreement_to_standard) {
      $(`#${media_or_organization}_morphosource_use_agreement_type`).val('Standard');
      permissive_option.attr('disabled','disabled');
    }
    else {
      permissive_option.removeAttr('disabled');
    }
    morphoSourceUseAgreementChange(media_or_organization);
  };

  var limitRequiredArchival = function(media_or_organization, required_archival_value) {
    $(`select#${media_or_organization}_required_archival_of_published_derivatives`).val(required_archival_value);
    $(`select#${media_or_organization}_required_archival_of_published_derivatives option[value!="${required_archival_value}"]`).attr('disabled','disabled');
  };

  var unrestrictRequiredArchival = function(media_or_organization) {
    $(`select#${media_or_organization}_required_archival_of_published_derivatives option`).removeAttr('disabled');
  };

  var limit3DUse = function(media_or_organization, required_3d_use_value) {
    $(`select#${media_or_organization}_permits_3d_use`).val(required_3d_use_value);
    $(`select#${media_or_organization}_permits_3d_use option[value!="${required_3d_use_value}"]`).attr('disabled','disabled');
  };

  var unrestrict3DUse = function(media_or_organization) {
    $(`select#${media_or_organization}_permits_3d_use option`).removeAttr('disabled');
  };

  var setCommercialUsePermitted = function(media_or_organization, commercial_use_permitted, force_commercial_use_permitted) {
    var commercial_use_permitted_option = $(`select[name="${media_or_organization}[permits_commercial_use]"] option[value="CommercialUsePermitted"]`);
    var commercial_use_not_permitted_option = $(`select[name="${media_or_organization}[permits_commercial_use]"] option[value="CommercialUseNotPermitted"]`);
    if (commercial_use_permitted) {
      commercial_use_permitted_option.removeAttr('disabled');
      if (force_commercial_use_permitted) {
        $(`select[name="${media_or_organization}[permits_commercial_use]"]`).val('CommercialUsePermitted');
        commercial_use_not_permitted_option.attr('disabled','disabled');
      }
      else {
        commercial_use_not_permitted_option.removeAttr('disabled');
      }
    }
    else {
      commercial_use_not_permitted_option.removeAttr('disabled');
      $(`select[name="${media_or_organization}[permits_commercial_use]"]`).val('CommercialUseNotPermitted');
      commercial_use_permitted_option.attr('disabled', 'disabled');
    }
  };

  var disableLicense = function(media_or_organization, licenses) {
    $(`select[name="${media_or_organization}[license]"] option`).each(function() {
      // Disable options
      if ( licenses.includes( $(this).val() ) ) {
        // Remove select value if disabled selected
        if ( $(`select[name="${media_or_organization}[license]"]`).val() == $(this).val() ) {
          $(`select[name="${media_or_organization}[license]"]`).val('');
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

  // When a license statement is selected, prune commercial use options
  $('select[name="media[license]"]').change(function() {
    event.preventDefault();
    licenseChange('media');
  });

  $('select[name="organization[license]"]').change(function() {
    event.preventDefault();
    licenseChange('organization');
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
  });
});
