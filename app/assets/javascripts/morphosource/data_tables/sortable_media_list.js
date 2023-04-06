$( document ).ready(function() {
    // initialize sortable
    $("#sortable-media-list").sortable();
    $("#save-media-order").on("click", function() {
      $("#save-media-order").prop('disabled', true);
      $.ajax({
        url: $("#sortable-media-list").data("url"),
        type: "GET",
        data: new URLSearchParams({'sort': $("#sortable-media-list").data("sort"), page: $("#sortable-media-list").data("page"), per_page: $("#sortable-media-list").data("per-page")}).toString() + '&' + $("#sortable-media-list").sortable('serialize')
      });
    // }
  });
})
