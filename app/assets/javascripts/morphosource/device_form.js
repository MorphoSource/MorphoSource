
$( document ).ready(function() {
  if ($('form[id*="edit_device"]').length) { // if device form page

    removeLastRepeatable();

    $(document).on("submit", 'form[data-param-key="device"]', function() {
      disablePage();
    })
  }
});