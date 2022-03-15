//= require morphosource/data_tables/cho_table

$(document).ready(function() {

    if ($('body[class*="media-works"]').length || $('body[class*="teams"]').length) { // check if the page is dashboard media works

    var choTable = createCulturalHeritageObjectTable('#datatable-cho-list');

    $('.choose-columns-cho .toggle-vis').on( 'click', function (e) {
      var column = choTable.column( $(this).attr('data-column') );
      column.visible( ! column.visible() );
    });

  } // / end if dashboard media works

});
