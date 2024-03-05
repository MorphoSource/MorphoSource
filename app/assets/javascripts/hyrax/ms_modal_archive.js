$(document).ready(function() {
  $('a#modal-archive-info-toggle').click(function(event) {
    event.preventDefault();
    $('#modal-archive-info').modal();

    const toggleError = function() {
      $('div#archive-contents-file-list').hide();
      $('div#archive-contents-error-message').show();
    }

    // Load file archive contents dynamically
    const mediaID = $(this).data('mediaId');
    if (mediaID) {
      $.ajax({
        url: `/concern/media/${mediaID}/modal/archive-contents`,
        error: () => toggleError(),
        timeout: 10000 //in milliseconds
    });
    } else {
      toggleError();
    }
  })
});