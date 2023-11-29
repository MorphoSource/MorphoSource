// Used for media permissions fields on media edit and team-linked organization edit
$( document ).ready(function() {
  var media_edit_form = $('form[id*="edit_media"]');
  var organization_edit_form = $('form[id*="edit_organization"]');

  if ($('form[id*="edit_organization"]').length) {
    if ($('form[id*="edit_organization_collection"]').length) {
      var model = 'organization_collection'
    } else {
      var model = 'organization'
    }
  } else if ($('form[id*="edit_media"]').length) {
    var model = 'media'
  }

  if ( media_edit_form.length || organization_edit_form.length ) {
    console.log('on edit org or media')
    downloadPermission();
  }

  // Manages the download permission dropdown menu
  // Hidden input is created by morphosource/permissions_helper
  function downloadPermission() {
    $(".download-permission-dropdown a").click(function () {
      console.log('clicked')
        var selectedText = $(this).text();
        var selectedValue = $(this).attr('id');
        var hiddenField = $("[id*='_download_permission']")
        hiddenField.val(selectedValue);
        var spanClass = $(this).find('span').attr('class');
        var span = '<span style="height:110%;" class="' + spanClass + '">';
        $(this).parents('.btn-group').find('.dropdown-toggle').html(span + selectedText + '</span><span class="glyphicon glyphicon-chevron-down" style="font-size:10px; color: black;"></span>');
    });
  }
})
