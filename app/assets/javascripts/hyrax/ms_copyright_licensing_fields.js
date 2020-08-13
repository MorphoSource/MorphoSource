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
        setCommercialUsePermitted(media_or_organization, true);
        break;
      case '1':
        disableLicense(media_or_organization, ['http://creativecommons.org/publicdomain/mark/1.0/']);
        setCommercialUsePermitted(media_or_organization, true);
        break;
      case '2':
        disableLicense(media_or_organization, ['https://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by-sa/4.0/', 'https://creativecommons.org/licenses/by-nd/4.0/', 'http://creativecommons.org/publicdomain/zero/1.0/', 'http://creativecommons.org/publicdomain/mark/1.0/']);
        setCommercialUsePermitted(media_or_organization, false);
        break;
      case '3':
        disableLicense(media_or_organization, ['https://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by-sa/4.0/', 'https://creativecommons.org/licenses/by-nd/4.0/', 'https://creativecommons.org/licenses/by-nc/4.0/', 'https://creativecommons.org/licenses/by-nc-nd/4.0/', 'https://creativecommons.org/licenses/by-nc-sa/4.0/']);
        setCommercialUsePermitted(media_or_organization, true);
        break;
      case '4':
        disableLicense(media_or_organization, ['https://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by-sa/4.0/', 'https://creativecommons.org/licenses/by-nd/4.0/', 'https://creativecommons.org/licenses/by-nc/4.0/', 'https://creativecommons.org/licenses/by-nc-nd/4.0/', 'https://creativecommons.org/licenses/by-nc-sa/4.0/']);
        setCommercialUsePermitted(media_or_organization, false);
        break;
      default:
        break;
    }
  };

  var licenseChange = function(media_or_organization) {
    if ( /\/by-nc/.test($(`select#${media_or_organization}_license`).val()) ) {
      setCommercialUsePermitted(media_or_organization, false);
    }
    else {
      setCommercialUsePermitted(media_or_organization, true);
    }
  };

  var setCommercialUsePermitted = function(media_or_organization, commercial_use_permitted) {
    var commercial_use_permitted_option = $(`select[name="${media_or_organization}[permits_commercial_use]"] option[value="CommercialUsePermitted"]`);
    if (commercial_use_permitted) {
      commercial_use_permitted_option.removeAttr('disabled');
    }
    else {
      if ($(`select[name="${media_or_organization}[permits_commercial_use]"]`).val() == commercial_use_permitted_option.val()) {
        $(`select[name="${media_or_organization}[permits_commercial_use]"]`).val('CommercialUseNotPermitted');
      }
      commercial_use_permitted_option.attr('disabled', 'disabled');
    }
  };

  var disableLicense = function(media_or_organization, licenses) {
    $(`select[name="${media_or_organization}[license][]"] option`).each(function() {
      // Disable options
      if ( licenses.includes( $(this).val() ) ) {
        // Remove select value if disabled selected
        if ( $(`select[name="${media_or_organization}[license][]"]`).val() == $(this).val() ) {
          $(`select[name="${media_or_organization}[license][]"]`).val('');
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
  $('select[name="media[license][]"]').change(function() {
    event.preventDefault();
    licenseChange('media');
  });

  $('select[name="organization[license][]"]').change(function() {
    event.preventDefault();
    licenseChange('organization');
  });
});
