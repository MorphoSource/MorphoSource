$(document).on('turbolinks:load', function() {
  // shared functions and listeners for copyright statement and licensing fields
  console.log('hallo');

  // TODO: Unify media and organization functions here

  // When a copyright statement is selected, check against license and prune available license options
  $('select[name="media[rights_statement]"]').change(function() {
    console.log('mm');
    event.preventDefault();

    var conditions = {
      0: ['http://rightsstatements.org/vocab/InC-RUU/1.0/'],
      1: ['http://rightsstatements.org/vocab/InC/1.0/', 'http://rightsstatements.org/vocab/InC-OW-EU/1.0/', 'http://rightsstatements.org/vocab/InC-EDU/1.0/'],
      2: ['http://rightsstatements.org/vocab/InC-NC/1.0/'],
      3: ['http://rightsstatements.org/vocab/NoC-CR/1.0/', 'http://rightsstatements.org/vocab/NoC-OKLR/1.0/', 'http://rightsstatements.org/vocab/NoC-NC/1.0/', 'http://rightsstatements.org/vocab/NoC-US/1.0/', 'http://rightsstatements.org/vocab/NKC/1.0/']
    }

    var conditionMatch = null;
    for (const property in conditions) {
      if ( conditions[property].includes( $('select#media_rights_statement').val() ) ) {
        conditionMatch = property;
      }
    }

    switch (conditionMatch) {
      case '0':
        disableLicense(['https://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by-sa/4.0/', 'https://creativecommons.org/licenses/by-nd/4.0/', 'https://creativecommons.org/licenses/by-nc/4.0/', 'https://creativecommons.org/licenses/by-nc-nd/4.0/', 'https://creativecommons.org/licenses/by-nc-sa/4.0/', 'http://creativecommons.org/publicdomain/zero/1.0/', 'http://creativecommons.org/publicdomain/mark/1.0/', 'http://www.morphosource.org/terms/licenseUnknown/']);
        break;
      case '1':
        disableLicense(['http://creativecommons.org/publicdomain/mark/1.0/']);
        break;
      case '2':
        disableLicense(['https://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by-sa/4.0/', 'https://creativecommons.org/licenses/by-nd/4.0/', 'http://creativecommons.org/publicdomain/zero/1.0/', 'http://creativecommons.org/publicdomain/mark/1.0/']);
        break;
      case '3':
        disableLicense(['https://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by-sa/4.0/', 'https://creativecommons.org/licenses/by-nd/4.0/', 'https://creativecommons.org/licenses/by-nc/4.0/', 'https://creativecommons.org/licenses/by-nc-nd/4.0/', 'https://creativecommons.org/licenses/by-nc-sa/4.0/']);
        break;
      default:
        break;
    }
  });

  var disableLicense = function(licenses) {
    $('select[name="media[license][]"] option').each(function() {
      // Disable options
      if ( licenses.includes( $(this).val() ) ) {
        // Remove select value if disabled selected
        if ( $('select[name="media[license][]"]').val() == $(this).val() ) {
          $('select[name="media[license][]"]').val('');
        }

        // Disable option
        $(this).attr('disabled', 'disabled');
      } else {
        $(this).removeAttr('disabled');
      }
    });
  };

  $('select[name="organization[rights_statement]"]').change(function() {
    console.log('mm');
    event.preventDefault();

    var conditions = {
      0: ['http://rightsstatements.org/vocab/InC-RUU/1.0/'],
      1: ['http://rightsstatements.org/vocab/InC/1.0/', 'http://rightsstatements.org/vocab/InC-OW-EU/1.0/', 'http://rightsstatements.org/vocab/InC-EDU/1.0/'],
      2: ['http://rightsstatements.org/vocab/InC-NC/1.0/'],
      3: ['http://rightsstatements.org/vocab/NoC-CR/1.0/', 'http://rightsstatements.org/vocab/NoC-OKLR/1.0/', 'http://rightsstatements.org/vocab/NoC-NC/1.0/', 'http://rightsstatements.org/vocab/NoC-US/1.0/', 'http://rightsstatements.org/vocab/NKC/1.0/']
    }

    var conditionMatch = null;
    for (const property in conditions) {
      if ( conditions[property].includes( $('select#organization_rights_statement').val() ) ) {
        conditionMatch = property;
      }
    }

    switch (conditionMatch) {
      case '0':
        disableLicense(['https://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by-sa/4.0/', 'https://creativecommons.org/licenses/by-nd/4.0/', 'https://creativecommons.org/licenses/by-nc/4.0/', 'https://creativecommons.org/licenses/by-nc-nd/4.0/', 'https://creativecommons.org/licenses/by-nc-sa/4.0/', 'http://creativecommons.org/publicdomain/zero/1.0/', 'http://creativecommons.org/publicdomain/mark/1.0/', 'http://www.morphosource.org/terms/licenseUnknown/']);
        break;
      case '1':
        disableLicense(['http://creativecommons.org/publicdomain/mark/1.0/']);
        break;
      case '2':
        disableLicense(['https://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by-sa/4.0/', 'https://creativecommons.org/licenses/by-nd/4.0/', 'http://creativecommons.org/publicdomain/zero/1.0/', 'http://creativecommons.org/publicdomain/mark/1.0/']);
        break;
      case '3':
        disableLicense(['https://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by-sa/4.0/', 'https://creativecommons.org/licenses/by-nd/4.0/', 'https://creativecommons.org/licenses/by-nc/4.0/', 'https://creativecommons.org/licenses/by-nc-nd/4.0/', 'https://creativecommons.org/licenses/by-nc-sa/4.0/']);
        break;
      default:
        disableLicense([]);
        break;
    }
  });

  var disableLicense = function(licenses) {
    $('select[name="organization[license][]"] option').each(function() {
      // Disable options
      if ( licenses.includes( $(this).val() ) ) {
        // Remove select value if disabled selected
        if ( $('select[name="organization[license][]"]').val() == $(this).val() ) {
          $('select[name="organization[license][]"]').val('');
        }

        // Disable option
        $(this).attr('disabled', 'disabled');
      } else {
        $(this).removeAttr('disabled');
      }
    });
  };
});