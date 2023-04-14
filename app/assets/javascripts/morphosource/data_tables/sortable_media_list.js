$( document ).ready(function() {
    // initialize sortable
    $("#sortable-media-list").sortable({
      handle: ".sort-handle"
    });
    
    $("#save-media-order").on("click", function() {
      $("#save-media-order").addClass("disabled");
      $.loader.open({ imgUrl: "/loading32x32.gif" });
      $.ajax({
        url: $("#sortable-media-list").data("url"),
        type: "GET",
        data: new URLSearchParams({'sort': $("#sortable-media-list").data("sort"), page: $("#sortable-media-list").data("page"), per_page: $("#sortable-media-list").data("per-page")}).toString() + '&' + $("#sortable-media-list").sortable('serialize')
      });
    // }
  });
})
