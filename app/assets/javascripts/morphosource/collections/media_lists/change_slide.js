$(document).on('click', "#viewer-next", function(){
  loadNextSlide('next');
});

$(document).on('click', "#viewer-previous", function(){
  loadNextSlide('previous');
});

function loadNextSlide(view) {
  $.ajax({
    url: "/media_lists/" + $('#collection-id').text() + "/change_slide",
    type: "GET",
    data: new URLSearchParams({current_id: $("#current_viewer_id").text(), view: view}).toString() + '&' + $("#sortable-media-list").sortable('serialize')
  });
}
