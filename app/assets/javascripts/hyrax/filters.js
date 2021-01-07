$(document).ready(function() {
    // if the page has filter form
    if ( $('form.filters').length ) { // if page has filter form
      $('form.filters select').change(function() {
        syncFilters($(this).attr('name'), $(this).val()); // sync any filter needed
        var form_id = $(this).data('form');
        disablePage();
        $('#'+form_id).submit();
      });

      $('[data-behavior="remove-filter"]').on('click', function (e) {
        removing_param = $(this).data('param');
        if (removing_param == 'all') {
          $('.filter-param').remove();
        } else {
          $('input[name=' + removing_param + ']').remove();
          $('p[id=' + removing_param + ']').remove();
          removeSyncFilters(removing_param);
        }
        var form_id = $(this).data('form');
        disablePage();
        $('#'+form_id).submit();
      });
    } // end if filter form
});

function syncFilters(name, value) {
  $('[data-sync="' + name + '"]').each(function() {
    $(this).val(value);
  })
}

function removeSyncFilters(name) {
  $('[data-sync="' + name + '"]').each(function() {
    $(this).remove();
  })
}
