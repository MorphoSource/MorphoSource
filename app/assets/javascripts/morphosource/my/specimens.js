//= require morphosource/data_tables/bso_table

$(document).ready(function() {

    if ($('body[class*="media-works"]').length || $('body[class*="teams"]').length) { // check if the page is dashboard media works

    var bsoTable = createBiologicalSpecimenTable('#datatable-bso-list');

    $('.choose-columns-bso .toggle-vis').on( 'click', function (e) {
      var column = bsoTable.column( $(this).attr('data-column') );
      column.visible( ! column.visible() );
    });

  }

});
