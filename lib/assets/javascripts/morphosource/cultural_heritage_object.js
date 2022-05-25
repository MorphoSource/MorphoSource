$( document ).ready(function() {

  // for any getty fields with selected values, create an empty search box at the top of the values list. Hide the remove button next to the search box.
  $("div[data-autocomplete-url*='getty']").each((_idx, getty_field) => {
    if ($(getty_field).find('.select2-container:not(.select2-container-disabled)').length) {
      return
    } else {
      $.when($(getty_field).find('.add').first().trigger("click")).then($(getty_field).find('.remove').first().css("visibility", "hidden"));
    }
  });

});
